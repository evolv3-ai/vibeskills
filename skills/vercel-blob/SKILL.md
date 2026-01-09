---
name: vercel-blob
description: |
  Integrate Vercel Blob for file uploads and CDN-delivered assets in Next.js. Supports client-side uploads with presigned URLs and multipart transfers for large files.

  Use when implementing file uploads (images, PDFs, videos) or troubleshooting missing tokens, size limits, or client upload failures.
---

# Vercel Blob

**Last Updated**: 2026-01-09
**Version**: @vercel/blob@2.0.0

---

## Quick Start

```bash
# Create Blob store: Vercel Dashboard → Storage → Blob
vercel env pull .env.local  # Creates BLOB_READ_WRITE_TOKEN
npm install @vercel/blob
```

**Server Upload**:
```typescript
'use server';
import { put } from '@vercel/blob';

export async function uploadFile(formData: FormData) {
  const file = formData.get('file') as File;
  const blob = await put(file.name, file, { access: 'public' });
  return blob.url;
}
```

**CRITICAL**: Never expose `BLOB_READ_WRITE_TOKEN` to client. Use `handleUpload()` for client uploads.

---

## Client Upload (Secure)

**Server Action** (generates presigned token):
```typescript
'use server';
import { handleUpload } from '@vercel/blob/client';

export async function getUploadToken(filename: string) {
  return await handleUpload({
    body: {
      type: 'blob.generate-client-token',
      payload: { pathname: `uploads/${filename}`, access: 'public' }
    },
    request: new Request('https://dummy'),
    onBeforeGenerateToken: async (pathname) => ({
      allowedContentTypes: ['image/jpeg', 'image/png'],
      maximumSizeInBytes: 5 * 1024 * 1024
    })
  });
}
```

**Client Component**:
```typescript
'use client';
import { upload } from '@vercel/blob/client';

const tokenResponse = await getUploadToken(file.name);
const blob = await upload(file.name, file, {
  access: 'public',
  handleUploadUrl: tokenResponse.url
});
```

---

## File Management

**List/Delete**:
```typescript
import { list, del } from '@vercel/blob';

// List with pagination
const { blobs, cursor } = await list({ prefix: 'uploads/', cursor });

// Delete
await del(blobUrl);
```

**Multipart (>500MB)**:
```typescript
import { createMultipartUpload, uploadPart, completeMultipartUpload } from '@vercel/blob';

const upload = await createMultipartUpload('large-video.mp4', { access: 'public' });
// Upload chunks in loop...
await completeMultipartUpload({ uploadId: upload.uploadId, parts });
```

---

## Critical Rules

**Always**:
- ✅ Use `handleUpload()` for client uploads (never expose `BLOB_READ_WRITE_TOKEN`)
- ✅ Validate file type/size before upload
- ✅ Use pathname organization (`avatars/`, `uploads/`)
- ✅ Add timestamp/UUID to filenames (avoid collisions)

**Never**:
- ❌ Expose `BLOB_READ_WRITE_TOKEN` to client
- ❌ Upload >500MB without multipart
- ❌ Skip file validation

---

## Known Issues Prevention

This skill prevents **10 documented issues**:

### Issue #1: Missing Environment Variable
**Error**: `Error: BLOB_READ_WRITE_TOKEN is not defined`
**Source**: https://vercel.com/docs/storage/vercel-blob
**Why It Happens**: Token not set in environment
**Prevention**: Run `vercel env pull .env.local` and ensure `.env.local` in `.gitignore`.

### Issue #2: Client Upload Token Exposed
**Error**: Security vulnerability, unauthorized uploads
**Source**: https://vercel.com/docs/storage/vercel-blob/client-upload
**Why It Happens**: Using `BLOB_READ_WRITE_TOKEN` directly in client code
**Prevention**: Use `handleUpload()` to generate client-specific tokens with constraints.

### Issue #3: File Size Limit Exceeded
**Error**: `Error: File size exceeds limit` (500MB)
**Source**: https://vercel.com/docs/storage/vercel-blob/limits
**Why It Happens**: Uploading file >500MB without multipart upload
**Prevention**: Validate file size before upload, use multipart upload for large files.

### Issue #4: Wrong Content-Type
**Error**: Browser downloads file instead of displaying (e.g., PDF opens as text)
**Source**: Production debugging
**Why It Happens**: Not setting `contentType` option, Blob guesses incorrectly
**Prevention**: Always set `contentType: file.type` or explicit MIME type.

### Issue #5: Public File Not Cached
**Error**: Slow file delivery, high egress costs
**Source**: Vercel Blob best practices
**Why It Happens**: Using `access: 'private'` for files that should be public
**Prevention**: Use `access: 'public'` for publicly accessible files (CDN caching).

### Issue #6: List Pagination Not Handled
**Error**: Only first 1000 files returned, missing files
**Source**: https://vercel.com/docs/storage/vercel-blob/using-blob-sdk#list
**Why It Happens**: Not iterating with cursor for large file lists
**Prevention**: Use cursor-based pagination in loop until `cursor` is undefined.

### Issue #7: Delete Fails Silently
**Error**: Files not deleted, storage quota fills up
**Source**: https://github.com/vercel/storage/issues/150
**Why It Happens**: Using wrong URL format, blob not found
**Prevention**: Use full blob URL from `put()` response, check deletion result.

### Issue #8: Upload Timeout (Large Files)
**Error**: `Error: Request timeout` for files >100MB
**Source**: Vercel function timeout limits
**Why It Happens**: Serverless function timeout (10s free tier, 60s pro)
**Prevention**: Use client-side upload with `handleUpload()` for large files.

### Issue #9: Filename Collisions
**Error**: Files overwritten, data loss
**Source**: Production debugging
**Why It Happens**: Using same filename for multiple uploads
**Prevention**: Add timestamp/UUID: `` `uploads/${Date.now()}-${file.name}` `` or `addRandomSuffix: true`.

### Issue #10: Missing Upload Callback
**Error**: Upload completes but app state not updated
**Source**: https://vercel.com/docs/storage/vercel-blob/client-upload#callback-after-upload
**Why It Happens**: Not implementing `onUploadCompleted` callback
**Prevention**: Use `onUploadCompleted` in `handleUpload()` to update database/state.

---

## Common Patterns

**Avatar Upload with Replacement**:
```typescript
'use server';
import { put, del } from '@vercel/blob';

export async function updateAvatar(userId: string, formData: FormData) {
  const file = formData.get('avatar') as File;
  if (!file.type.startsWith('image/')) throw new Error('Only images allowed');

  const user = await db.query.users.findFirst({ where: eq(users.id, userId) });
  if (user?.avatarUrl) await del(user.avatarUrl); // Delete old

  const blob = await put(`avatars/${userId}.jpg`, file, { access: 'public' });
  await db.update(users).set({ avatarUrl: blob.url }).where(eq(users.id, userId));
  return blob.url;
}
```

**Protected Upload** (`access: 'private'`):
```typescript
const blob = await put(`documents/${userId}/${file.name}`, file, { access: 'private' });
```
