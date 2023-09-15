Run 

```bash
dart run bin/fizzbuzz.dart | pv -F 'current: %r, average: %a' > /dev/null
```

and if needed:
```bash
apt-get install pv
```

## Timings

| File | Hash | Time | Note |
| -- | -- | -- | -- |
| baseline.dart | 0131356564de8a875913351b953d01d3d9acedfb | 82.6MiB/s | Simple output |
| mosum.dart | 0131356564de8a875913351b953d01d3d9acedfb | 212MiB/s |  |
| mosum.dart | 13d2366878d1c02533125150842fe997097633ee | 219MiB/s | Unroll |
| mosum.dart | 020056a5f8f277bdbc97c715795f91c8be95a693 | 748MiB/s | Multiple isolates |