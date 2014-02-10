# Support Tools for B2GPerf

This is support tools for [B2GPerf](https://github.com/mozilla/b2gperf), which is a tool for testing the performance of Firefox OS.


## onekeyrun.sh

The `onekeyrun.sh` will launch apps which be listed in `appslist.txt`.

And then print output into `output.log`, `summary.txt`, and `summary.csv` files.

Please make sure the comma is your CSV Viewer's separator character.


### Requisites

* python 2.7
* virtualenv
* b2gperf


### Prepare the Running Environment

Create virtualenv for b2gperf and activate it.
```bash
$ virtualenv .b2gperf
$ source .b2gperf/bin/activate
```

Install b2gperf.
```bash
(.b2gperf)$ pip install b2gperf
```


### Edit Apps List

Edit `appslist.txt` to fit your requirement. You can refer to the `template-appslist.txt` file.
```bash
(.b2gperf)$ cp template-appslist.txt appslist.txt
(.b2gperf)$ <YOUR_EDITOR> appslist.txt
```


### Run

Run script and wait the result.
```bash
(.b2gperf)$ adb forward tcp:2828 tcp:2828
(.b2gperf)$ ./onekeyrun.sh
```

Then you can open `summary.txt` or `summary.csv`.
