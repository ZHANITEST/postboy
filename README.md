# postboy
postboy is ...
 - minimalist
 - quick and dirty
 - GET/POST client for DLang


# Requirment
 - DMD
 - DUB

# Using
## Clone it
```
git clone https://github.com/ZHANITEST/postboy
```

### Library
```
cd postboy
dub add-local ./
```
and add a `"postboy":"~master"` line in dub.json.

### API Documents
```
cd postboy
dub build --build=docs
cd docs
```

### Sample Application
```
cd postboy
dub test
./postboy-test-library
```


# Features
 - ✅ [REQ] GET
 - ✅ [REQ] POST
 - ✅ [RES] Byte
 - ✅ [RES] String(HTML)
 - ✅ Header Options
 
End! keep it simple.


# License
LGPL v2.1
