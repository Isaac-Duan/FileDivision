import streams

var strm = newFileStream("./aaa.wmv",fmRead)
var buff: array[1024,char]

strm.read(buff)
echo buff
echo strm.getPosition()
while true:
  for x in 0..1023:
    buff[x] = '\x00'
  try:
    strm.read(buff)
    echo strm.getPosition()
    echo buff.len()
  except:
    break
echo buff
echo buff.len()
strm.close()
