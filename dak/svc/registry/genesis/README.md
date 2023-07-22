# Genesis: registry 

## Usage, happy path

We are under `didalik` umbrella, so no need to `npm i`!

```
rm -rf svc; rm -f ~/.dak.svc.env; npm run i # in terminal 1
cd svc; make; cd -         # in terminal 2
cd svc; make install; cd - # in terminal 2
make                                        # in terminal 1
```

## Testing genesis locally

```
cd svc; npm run registry; cd - # in terminal 1
cd svc; npm run dev            # in terminal 2
cd svc; npm test               # in terminal 3
```
