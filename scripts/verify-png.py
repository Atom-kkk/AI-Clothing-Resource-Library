#!/usr/bin/env python3
"""全量体检 assets/png/ 下的 PNG：校验签名、逐块 CRC、IEND 结尾。

用法：python3 scripts/verify-png.py [--delete-bad] [--list]
退出码：0 = 全部完好；1 = 存在损坏
"""
import glob
import os
import struct
import sys
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PNG_DIR = os.path.join(ROOT, "assets", "png")
IEND = b"IEND\xaeB`\x82"


def check(path):
    """返回 None 表示完好，否则返回错误描述。"""
    d = open(path, "rb").read()
    if d[:8] != b"\x89PNG\r\n\x1a\n":
        return "签名错"
    if len(d) < 400000:
        return f"体积过小({len(d)})"
    i = 8
    saw_iend = False
    while i + 8 <= len(d):
        ln = struct.unpack(">I", d[i:i + 4])[0]
        typ = d[i + 4:i + 8]
        end = i + 12 + ln
        if end > len(d):
            return f"截断@{typ.decode('latin1')}"
        crc = struct.unpack(">I", d[i + 8 + ln:i + 12 + ln])[0]
        if zlib.crc32(d[i + 4:i + 8 + ln]) & 0xFFFFFFFF != crc:
            return f"CRC错@{typ.decode('latin1')}"
        i = end
        if typ == b"IEND":
            saw_iend = True
            break
    if not saw_iend:
        return "无IEND"
    if not d.endswith(IEND):
        return "尾部多余数据"
    if i != len(d):
        return "IEND 后还有数据"
    return None


def main():
    delete_bad = "--delete-bad" in sys.argv
    files = sorted(glob.glob(os.path.join(PNG_DIR, "*.png")))
    bad = []
    total_bytes = 0
    for p in files:
        err = check(p)
        if err:
            bad.append((os.path.basename(p)[:-4], err, os.path.getsize(p)))
        else:
            total_bytes += os.path.getsize(p)

    print(f"扫描 {len(files)} 张，完好 {len(files) - len(bad)} 张，损坏 {len(bad)} 张")
    if bad:
        for name, err, sz in bad[:20]:
            print(f"  {name}  {err}  {sz/1024:.0f} KB")
        if len(bad) > 20:
            print(f"  … 另有 {len(bad) - 20} 张")
        listfile = os.path.join(ROOT, "logs", "bad-png.txt")
        os.makedirs(os.path.dirname(listfile), exist_ok=True)
        with open(listfile, "w") as fh:
            fh.write("\n".join(b[0] for b in bad) + "\n")
        print(f"损坏清单：{listfile}")
        if delete_bad:
            for name, _, _ in bad:
                os.remove(os.path.join(PNG_DIR, name + ".png"))
            print(f"已删除 {len(bad)} 张损坏文件，重跑 fetch-all-png.sh 即可补齐")
    print(f"完好文件合计 {total_bytes / 1048576:.1f} MB")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
