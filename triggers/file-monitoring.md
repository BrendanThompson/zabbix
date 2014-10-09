# File Monitoring

## File Modified Comparison

This will check to see if the file has been modified within the last `5 minutes`

```
{myServer:vfs.file.time[/tmp/myFile.txt, modify].now(0)} - {myServer:vfs.file.time[/tmp/myFile.txt, modify].last(0)} > 300
```
