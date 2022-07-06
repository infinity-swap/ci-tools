# Google Cloud Storage Proxy

GCS allows only to have a public URL for some bucket.

On the other hand Google provide IAP that could limit access to other services via Oauth.

IAP does not work with GCS buckets. 

To server Oauth protected files from storage we could run IAP protected proxy service (instance) that would expose files from some private storage bucket.
