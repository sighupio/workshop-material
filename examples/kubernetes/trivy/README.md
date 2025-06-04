# Scan images with Trivy
Your objective here is to scan images in namespaces `applications` and `infra` for the vulnerabilities CVE-2021-28831 and CVE-2016-9841.
Manifests are provided alongside this file.

> [!TIP]
> Use `trivy image image:tag` to scan an image!

## Goal
Run Trivy against all the images found in the deployment and write a file with the list of the match of the CVE.

Compile a table that looks like the following (and put in a file called `solution.txt`)
For example:
```plaintext
image1:latest|CVE-2021-28831:yes|CVE-2016-9841:no
image2:latest|CVE-2021-28831:no|CVE-2016-9841:no
```

Please make sure that you put the image:tag as the first column, CVE-2021-28831 as second and CVE-2016-9841 as third and then run the following command:
```bash
cat solution.txt | sort | tr -d " \t\n\r" | sha256sum
```

You should obtain this exact hash!
```plaintext
366f535becbcdc6efbdb08387a915aa44cedfb8a0a4ee0284ba617f3a00e813a
```

## Credits
This challenge is taken from the killercoda environment! Thanks guys :)
