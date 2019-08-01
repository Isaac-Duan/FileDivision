import streams, os, strutils

echo "param count is: ", paramCount()
var rfilename = ""
var divnum:uint = 0
try:
  rfilename = paramStr(1)
  divnum = paramStr(2).parseUInt()
  echo "file name: ", rfilename, "  ", "Div parts: ", divnum
except:
  echo "Error: illegal params"
  quit(0)

var f:File
try:
  f = open(rfilename)
except:
  echo "Error: file not found"
  quit(0)

var filesize = f.getFileSize()
if filesize <= 0:
  raise newException(ValueError, "File size is 0")
  
var wbuff:seq[byte] = @[]
var blocksize = uint64(filesize /% divnum.int64) + 1
#需要使用setLen手动增长填充seq，默认填充0
wbuff.setLen(blocksize)
echo blocksize

for x in 0..divnum:
  #File的read_bytes方法不会自动增长seq，可以使用setLen方法扩充seq(默认填充0)
  var rlen = f.readBytes(wbuff, 0, blocksize)
  echo "读取数据量", rlen
  if rlen == 0:
    break
  var fw = open(rfilename & int(x).intToStr(), fmWrite)
  echo "正在写入", rfilename & int(x).intToStr()
  discard fw.writeBytes(wbuff, 0, rlen)
  fw.close()
  
f.close()  
