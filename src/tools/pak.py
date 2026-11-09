import struct, zlib, sys, os
def rstr(b,o):
    n=struct.unpack_from('<i',b,o)[0]; o+=4
    if n<0: s=b[o:o-2*n].decode('utf-16-le').rstrip('\0'); return s,o-2*n
    return b[o:o+n].rstrip(b'\0').decode(),o+n
def read_entry(b,o):
    off,cs,us,meth=struct.unpack_from('<QQQI',b,o); o+=28
    h=b[o:o+20]; o+=20; blocks=[]
    if meth:
        n=struct.unpack_from('<I',b,o)[0]; o+=4
        for i in range(n): blocks.append(struct.unpack_from('<QQ',b,o)); o+=16
    enc,bs=struct.unpack_from('<BI',b,o); o+=5
    return dict(off=off,cs=cs,us=us,meth=meth,hash=h,blocks=blocks,enc=enc,bs=bs),o
def unpack(path,out):
    b=open(path,'rb').read()
    f=b[-45:]; enc,magic,ver,io,isz=struct.unpack_from('<BIiQQ',f,0)
    assert magic==0x5A6F12E1, hex(magic)
    print('version',ver,'encrypted',enc)
    ix=b[io:io+isz]; mp,o=rstr(ix,0); n=struct.unpack_from('<i',ix,o)[0]; o+=4
    print('mount',mp,n)
    for i in range(n):
        name,o=rstr(ix,o); e,o=read_entry(ix,o)
        data=b''.join(zlib.decompress(b[s:t]) for s,t in e['blocks']) if e['meth'] else b[e['off']+53:e['off']+53+e['us']]
        p=os.path.join(out,name); os.makedirs(os.path.dirname(p) or out,exist_ok=True); open(p,'wb').write(data)
        print(name,len(data),e['us'])
if __name__=='__main__': unpack(sys.argv[1],sys.argv[2])

import hashlib
def wstr(s):
    e=s.encode()+b'\0'; return struct.pack('<i',len(e))+e
def entry_bytes(off,cs,us,h,blocks,bs):
    r=struct.pack('<QQQI',off,cs,us,1)+h+struct.pack('<I',len(blocks))
    for s,t in blocks: r+=struct.pack('<QQ',s,t)
    return r+struct.pack('<BI',0,bs)
def pack(files,mount,out,BS=0x10000):
    data=b''; index=[]
    for name,raw in files:
        chunks=[zlib.compress(raw[i:i+BS],9) for i in range(0,len(raw),BS)] or [zlib.compress(b'',9)]
        comp=b''.join(chunks); h=hashlib.sha1(comp).digest()
        hdr_len=len(entry_bytes(0,0,0,h,[(0,0)]*len(chunks),0))
        start=len(data)+hdr_len; blocks=[]
        for c in chunks: blocks.append((start,start+len(c))); start+=len(c)
        bs=min(BS,len(raw)) if len(chunks)==1 else BS
        off=len(data)
        data+=entry_bytes(0,len(comp),len(raw),h,blocks,bs)+comp
        index.append((name,entry_bytes(off,len(comp),len(raw),h,blocks,bs)))
    ix=wstr(mount)+struct.pack('<i',len(index))+b''.join(wstr(n)+e for n,e in index)
    foot=struct.pack('<BIiQQ',0,0x5A6F12E1,3,len(data),len(ix))+hashlib.sha1(ix).digest()
    open(out,'wb').write(data+ix+foot)
