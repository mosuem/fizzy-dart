Run 

```bash
dart run bin/fizzbuzz.dart | pv -F 'current: %r, average: %a' > /dev/null
```

and if needed:
```bash
apt-get install pv
```