import streams, os, strutils, sequtils, tables

proc combineFile() =
  var fileseq = newSeq[string]()
  #walkFiles使用通配符来列举目录下的文件名称
  for tmpf in walkFiles("*.divpart"):
    var length = tmpf.len()
    fileseq.add(tmpf[0..length-9])
  #tables Table即是键值对数据结构
  var distFileTable = initTable[string, int]()

  for x in fileseq:
    var fnseq = x.split('.')
    var fnseqlen = fnseq.len()
    if fnseqlen >= 2 and fnseq[fnseqlen-1].isDigit() and distFileTable.hasKeyOrPut(fnseq[0..fnseqlen-2].join("."), 0):
      distFileTable[fnseq[0..fnseqlen-2].join(".")] += 1
  for k,v in distFileTable.pairs():
    var distfile = open(["comb",k].join(), fmWrite)
    for v1 in 0..v:
      var srcfile = open([k, ".", v1.intToStr(), ".divpart"].join(), fmRead)
      var buff: array[1024, byte]
      while true:
        #addr 取地址
        #read 通常返回读入的数据量
        var rlen = srcfile.readBuffer(addr(buff), 1024)
        if rlen <= 0:
          srcfile.close()
          break
        else:
          discard distfile.writeBuffer(addr(buff), rlen)
    distfile.close()
    echo k, "合并完毕"
  

echo "param count is: ", paramCount()
if paramCount() == 0:
  echo "合并文件"
  combineFile()
  quit(0)
  
var rfilename = ""
var divnum:uint = 0
try:
  #paramStr、paramCount保存命令行参数信息
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
  raise newException(OSError, "Error: file size is 0")
  
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
  var fw = open(rfilename & "." & int(x).intToStr() & ".divpart", fmWrite)
  echo "正在写入", rfilename & "." & int(x).intToStr() & ".divpart"
  discard fw.writeBytes(wbuff, 0, rlen)
  fw.close()
  
f.close()
