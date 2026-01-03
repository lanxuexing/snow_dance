# Angular文件下载

> Date: 2019-10-01
> Category: Blog


```typescript
// 文件下载
downloadPdf(id: number) {
  this.http.post('/api/documents', { id })
    .subscribe(
      (base64Pdf: string) => {
        const arrayBuffer = base64ToArrayBuffer(base64Pdf); // 创建Array缓冲区
        createAndDownloadBlobFile(arrayBuffer, 'testName');
      },
      error => console.error(error)
    )
}

// Base64到数组缓冲区
export function base64ToArrayBuffer(base64: string) {
  const binaryString = window.atob(base64); //如果不使用base64，则注释这个
  const bytes = new Uint8Array(binaryString.length);
  return bytes.map((byte, i) => binaryString.charCodeAt(i));
}

// 创建Blob对象并下载文件
createAndDownloadBlobFile(body, filename, extension = 'pdf') {
  const blob = new Blob([body]);
  const fileName = `${filename}.${extension}`;
  if (navigator.msSaveBlob) {
    // IE 10+
    navigator.msSaveBlob(blob, fileName);
  } else {
    const link = document.createElement('a');
    //支持HTML5下载属性的浏览器
    if (link.download !== undefined) {
      const url = URL.createObjectURL(blob);
      link.setAttribute('href', url);
      link.setAttribute('download', fileName);
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  }
}
```
