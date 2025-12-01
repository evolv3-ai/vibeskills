---
name: cloudflare-r2
description: |
  Store objects with R2's S3-compatible storage on Cloudflare's edge. Use when: uploading/downloading files, configuring CORS, generating presigned URLs, multipart uploads, managing metadata, or troubleshooting R2_ERROR, CORS failures, presigned URL issues, or quota errors.
---

# Cloudflare R2 Object Storage

**Status**: Production Ready ✅
**Last Updated**: 2025-11-24
**Dependencies**: cloudflare-worker-base (for Worker setup)
**Latest Versions**: wrangler@4.50.0, @cloudflare/workers-types@4.20251121.0, aws4fetch@1.0.20

**Recent Updates (2025)**:
- **September 2025**: R2 SQL open beta (serverless query engine for Apache Iceberg), Pipelines GA (real-time stream ingestion), Remote bindings GA (local dev connects to deployed R2)
- **May 2025**: Dashboard redesign (deeplink support, bucket settings centralization), Super Slurper 5x faster (rebuilt with Workers/Queues/Durable Objects)
- **April 2025**: R2 Data Catalog open beta (managed Apache Iceberg catalog), Event Notifications open beta (5,000 msg/s per Queue)
- **2025**: Bucket limits increased (1 million max), CRC-64/NVME checksums, Server-side encryption with customer keys, Infrequent Access storage class (beta), Oceania region, S3 API enhancements (sha256/sha1 checksums, ListParts, conditional CopyObject)

---

## Quick Start (5 Minutes)

```bash
# 1. Create bucket
npx wrangler r2 bucket create my-bucket

# 2. Add binding to wrangler.jsonc
# {
#   "r2_buckets": [{
#     "binding": "MY_BUCKET",
#     "bucket_name": "my-bucket",
#     "preview_bucket_name": "my-bucket-preview"  // Optional: separate dev/prod
#   }]
# }

# 3. Upload/download from Worker
type Bindings = { MY_BUCKET: R2Bucket };

// Upload
await env.MY_BUCKET.put('file.txt', data, {
  httpMetadata: { contentType: 'text/plain' }
});

// Download
const object = await env.MY_BUCKET.get('file.txt');
if (!object) return c.json({ error: 'Not found' }, 404);

return new Response(object.body, {
  headers: {
    'Content-Type': object.httpMetadata?.contentType || 'application/octet-stream',
    'ETag': object.httpEtag,
  },
});

# 4. Deploy
npx wrangler deploy
```

---

## R2 Workers API

### Core Methods

```typescript
// put() - Upload objects
await env.MY_BUCKET.put('file.txt', data, {
  httpMetadata: {
    contentType: 'text/plain',
    cacheControl: 'public, max-age=3600',
  },
  customMetadata: { userId: '123' },
  md5: await crypto.subtle.digest('MD5', data),  // Checksum verification
});

// Conditional upload (prevent overwrites)
const object = await env.MY_BUCKET.put('file.txt', data, {
  onlyIf: { uploadedBefore: new Date('2020-01-01') }
});
if (!object) return c.json({ error: 'File already exists' }, 409);

// get() - Download objects
const object = await env.MY_BUCKET.get('file.txt');
if (!object) return c.json({ error: 'Not found' }, 404);

const text = await object.text();           // As string
const json = await object.json();           // As JSON
const buffer = await object.arrayBuffer();  // As ArrayBuffer

// Range requests (partial downloads)
const partial = await env.MY_BUCKET.get('video.mp4', {
  range: { offset: 0, length: 1024 * 1024 }  // First 1MB
});

// head() - Get metadata only (no body download)
const object = await env.MY_BUCKET.head('file.txt');
console.log(object.size, object.etag, object.customMetadata);

// delete() - Delete objects
await env.MY_BUCKET.delete('file.txt');  // Single delete (idempotent)
await env.MY_BUCKET.delete(['file1.txt', 'file2.txt']);  // Bulk delete (max 1000)

// list() - List objects
const listed = await env.MY_BUCKET.list({
  prefix: 'images/',  // Filter by prefix
  limit: 100,
  cursor: cursor,     // Pagination
  delimiter: '/',     // Folder-like listing
});

for (const object of listed.objects) {
  console.log(`${object.key}: ${object.size} bytes`);
}
```

---

## Multipart Uploads

For files >100MB or resumable uploads. Use when: large files, browser uploads, parallelization needed.

```typescript
// 1. Create multipart upload
const multipart = await env.MY_BUCKET.createMultipartUpload('large-file.zip', {
  httpMetadata: { contentType: 'application/zip' }
});

// 2. Upload parts (5MB-100MB each, max 10,000 parts)
const multipart = env.MY_BUCKET.resumeMultipartUpload(key, uploadId);
const part1 = await multipart.uploadPart(1, chunk1);
const part2 = await multipart.uploadPart(2, chunk2);

// 3. Complete upload
const object = await multipart.complete([
  { partNumber: 1, etag: part1.etag },
  { partNumber: 2, etag: part2.etag },
]);

// 4. Abort if needed
await multipart.abort();
```

**Limits**: Parts 5MB-100MB, max 10,000 parts per upload. Don't use for files <5MB (overhead).

---

## Presigned URLs

Allow clients to upload/download directly to/from R2 (bypasses Worker). Use aws4fetch library.

```typescript
import { AwsClient } from 'aws4fetch';

const r2Client = new AwsClient({
  accessKeyId: env.R2_ACCESS_KEY_ID,
  secretAccessKey: env.R2_SECRET_ACCESS_KEY,
});

const url = new URL(
  `https://${bucketName}.${accountId}.r2.cloudflarestorage.com/${filename}`
);
url.searchParams.set('X-Amz-Expires', '3600');  // 1 hour expiry

const signed = await r2Client.sign(
  new Request(url, { method: 'PUT' }),  // or 'GET' for downloads
  { aws: { signQuery: true } }
);

// Client uploads directly to R2
await fetch(signed.url, { method: 'PUT', body: file });
```

**CRITICAL Security:**
- ❌ **NEVER** expose R2 access keys in client-side code
- ✅ **ALWAYS** generate presigned URLs server-side
- ✅ **ALWAYS** set expiry times (1-24 hours typical)
- ✅ **ALWAYS** add authentication before generating URLs
- ✅ **CONSIDER** scoping to user folders: `users/${userId}/${filename}`

---

## CORS Configuration

Configure CORS in bucket settings (Dashboard → R2 → Bucket → Settings → CORS Policy) before browser access.

```json
{
  "CORSRules": [{
    "AllowedOrigins": ["https://app.example.com"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
    "AllowedHeaders": ["Content-Type", "Content-MD5", "x-amz-meta-*"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3600
  }]
}
```

**For presigned URLs**: CORS handled by R2 directly (configure on bucket, not Worker).

---

## HTTP Metadata & Custom Metadata

```typescript
// HTTP metadata (standard headers)
await env.MY_BUCKET.put('file.pdf', data, {
  httpMetadata: {
    contentType: 'application/pdf',
    cacheControl: 'public, max-age=31536000, immutable',
    contentDisposition: 'attachment; filename="report.pdf"',
    contentEncoding: 'gzip',
  },
  customMetadata: {
    userId: '12345',
    version: '1.0',
  }  // Max 2KB total, keys/values must be strings
});

// Read metadata
const object = await env.MY_BUCKET.head('file.pdf');
console.log(object.httpMetadata, object.customMetadata);
```

---

## Error Handling

### Common R2 Errors

```typescript
try {
  await env.MY_BUCKET.put(key, data);
} catch (error: any) {
  const message = error.message;

  if (message.includes('R2_ERROR')) {
    // Generic R2 error
  } else if (message.includes('exceeded')) {
    // Quota exceeded
  } else if (message.includes('precondition')) {
    // Conditional operation failed
  } else if (message.includes('multipart')) {
    // Multipart upload error
  }

  console.error('R2 Error:', message);
  return c.json({ error: 'Storage operation failed' }, 500);
}
```

### Retry Logic

```typescript
async function r2WithRetry<T>(
  operation: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error: any) {
      const message = error.message;

      // Retry on transient errors
      const isRetryable =
        message.includes('network') ||
        message.includes('timeout') ||
        message.includes('temporarily unavailable');

      if (!isRetryable || attempt === maxRetries - 1) {
        throw error;
      }

      // Exponential backoff
      const delay = Math.min(1000 * Math.pow(2, attempt), 5000);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }

  throw new Error('Retry logic failed');
}

// Usage
const object = await r2WithRetry(() =>
  env.MY_BUCKET.get('important-file.txt')
);
```

---

## Performance Optimization

```typescript
// Batch delete (up to 1000 keys)
await env.MY_BUCKET.delete(['file1.txt', 'file2.txt', 'file3.txt']);

// Range requests for large files
const partial = await env.MY_BUCKET.get('video.mp4', {
  range: { offset: 0, length: 10 * 1024 * 1024 }  // First 10MB
});

// Cache headers for immutable assets
await env.MY_BUCKET.put('static/app.abc123.js', jsData, {
  httpMetadata: { cacheControl: 'public, max-age=31536000, immutable' }
});

// Checksums for data integrity
const md5Hash = await crypto.subtle.digest('MD5', fileData);
await env.MY_BUCKET.put('important.dat', fileData, { md5: md5Hash });
```

---

## Best Practices Summary

**Always Do:**
- Set `contentType` for all uploads
- Use batch delete for multiple objects (up to 1000)
- Set cache headers for static assets
- Use presigned URLs for large client uploads
- Use multipart for files >100MB
- Set CORS before browser uploads
- Set expiry times on presigned URLs (1-24 hours)
- Use `head()` when you only need metadata
- Use conditional operations to prevent overwrites

**Never Do:**
- Never expose R2 access keys in client-side code
- Never skip `contentType` (files download as binary)
- Never delete in loops (use batch delete)
- Never skip CORS for browser uploads
- Never use multipart for small files (<5MB)
- Never delete >1000 keys in single call
- Never skip presigned URL expiry (security risk)

---

## Known Issues Prevented

| Issue | Description | How to Avoid |
|-------|-------------|--------------|
| **CORS errors in browser** | Browser can't upload/download due to missing CORS policy | Configure CORS in bucket settings before browser access |
| **Files download as binary** | Missing content-type causes browsers to download files instead of display | Always set `httpMetadata.contentType` on upload |
| **Presigned URL expiry** | URLs never expire, posing security risk | Always set `X-Amz-Expires` (1-24 hours typical) |
| **Multipart upload limits** | Parts exceed 100MB or >10,000 parts | Keep parts 5MB-100MB, max 10,000 parts per upload |
| **Bulk delete limits** | Trying to delete >1000 keys fails | Chunk deletes into batches of 1000 |
| **Custom metadata overflow** | Metadata exceeds 2KB limit | Keep custom metadata under 2KB total |

---

## Wrangler Commands Reference

```bash
# Bucket management
wrangler r2 bucket create <BUCKET_NAME>
wrangler r2 bucket list
wrangler r2 bucket delete <BUCKET_NAME>

# Object management
wrangler r2 object put <BUCKET_NAME>/<KEY> --file=<FILE_PATH>
wrangler r2 object get <BUCKET_NAME>/<KEY> --file=<OUTPUT_PATH>
wrangler r2 object delete <BUCKET_NAME>/<KEY>

# List objects
wrangler r2 object list <BUCKET_NAME>
wrangler r2 object list <BUCKET_NAME> --prefix="folder/"
```

---

## Official Documentation

- **R2 Overview**: https://developers.cloudflare.com/r2/
- **Get Started**: https://developers.cloudflare.com/r2/get-started/
- **Workers API**: https://developers.cloudflare.com/r2/api/workers/workers-api-reference/
- **Multipart Upload**: https://developers.cloudflare.com/r2/api/workers/workers-multipart-usage/
- **Presigned URLs**: https://developers.cloudflare.com/r2/api/s3/presigned-urls/
- **CORS Configuration**: https://developers.cloudflare.com/r2/buckets/cors/
- **Public Buckets**: https://developers.cloudflare.com/r2/buckets/public-buckets/

---

**Ready to store with R2!** 🚀
