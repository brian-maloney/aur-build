#!/bin/bash
set -e

file_exists () {
  source ./PKGBUILD
  filename="${pkgname}-${pkgver}-${pkgrel}-x86_64.pkg.tar.zst"
  echo "Checking for $filename"
  retcode=$(curl -o /dev/null -s -Iw '%{http_code}' "https://aur.vond.net/$filename")
  if [[ "$retcode" -lt "300" ]]
  then
    return
  fi

  false
}

build_pkg () {
  git clone "https://aur.archlinux.org/$1.git"
  pushd $1
  if ! file_exists
  then
    makepkg --noconfirm $2
    for file in $(ls *.pkg.tar.zst)
    do
      cp "$file" /tmp/local-repo/
      repo-add -n /tmp/local-repo/vond.db.tar.xz "/tmp/local-repo/$file"
    done
  fi
  popd
}

echo "$SSH_CONFIG_BASE64" | base64 -d > ~/.ssh/config
echo "$SSH_KEY_BASE64" | base64 -d > ~/.ssh/id_ed25519
chmod 0600 ~/.ssh/id_ed25519
ssh-keyscan -p "$SSH_PORT" aur.vond.net > ~/.ssh/known_hosts

sudo pacman --noconfirm -Syu

mkdir -p /tmp/local-repo
rsync -ia aur@aur.vond.net:/opt/web-stack/aur/x86_64/vond* /tmp/local-repo/

aur sync --noconfirm --noview --repo vond --root /tmp/local-repo plex-media-server-plexpass
aur sync --noconfirm --noview --repo vond --root /tmp/local-repo sedutil
aur sync --noconfirm --noview --repo vond --root /tmp/local-repo nuttcp
aur sync --noconfirm --noview --repo vond --root /tmp/local-repo splunkforwarder
aur sync --noconfirm --noview --repo vond --root /tmp/local-repo fluent-bit

build_pkg freeipmi --skippgpcheck

### ZFS SECTION

sudo pacman --noconfirm -S linux-lts linux-lts-headers mkinitcpio

# Keyserver is unreliable, so we put these keys inline for now
#gpg --keyserver pgp.mit.edu --receive-keys 4F3BA9AB6D1F8D683DC2DFB56AD860EED4598027 # Tony Hutter (GPG key for signing ZFS releases) <hutter2@llnl.gov>
#gpg --keyserver pgp.mit.edu --receive-keys C33DF142657ED1F7C328A2960AB9E991C6AF658B # Brian Behlendorf (Master Branch)

# Tony Hutter (GPG key for signing ZFS releases) <hutter2@llnl.gov>
cat | gpg --import <<EOD
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=WTIO
-----END PGP PUBLIC KEY BLOCK-----
EOD

# Brian Behlendorf (LLNL) <behlendorf1@llnl.gov>
cat | gpg --import <<EOD
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQGiBEby9kIRBACl6ggDFcor8bG3nj1tFSBanC12CF5vo2oK7HxRBeEvKlBzqIfd
c6gcegZVGYm0EEMaW7ANjhdAm7LAuiC3PjhpMjvIh6f+jqiqYSI8XPjav9kLUXCq
R7bdwkpmUXe1PZ+fEbB1qAFCsueVzO2jNisnYB408yDBv9KGf6aUMk7CNwCg3XwG
2HObD4A6LvolmqaQp6t/N98D/2tFMKAiL/rIxCbownGA6blX22nJBkAcApCZswUi
jSZsjqXFRcWI9/+ckKyRpHYkGJUhiDykZ/kmw1ApLw+PQS3MXv+hfLfF34Dw5709
Xf9j/YW9Z7h/IYhR985p9vi0Kt2mZokeNulQMRC6M4QMPOloIW4XZ3d+FeKzua7r
zEc1A/9pBt9uozz6k+GnjAOGQsS655nHW8xGOekVasHbWICM7mflj+nqovLZJN5D
vxE5MyklQNV8tGQA9Pw9AZDKw5kY0kpyvdE/3b4Odtivr0NoAwVlIT5aIcr+wuLV
PVcGx9vZKGpkTPGcDbDRH9zBeLu1G3qt+1SMDjw6QFWUbH6yVbQnQnJpYW4gQmVo
bGVuZG9yZiA8YmVobGVuZG9yZjFAbGxubC5nb3Y+iGAEExECACAFAknEFzACGwMG
CwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRAKuemRxq9liy4PAKDYlprKOQCJkVpO
Y4N4OKi4Cl06nQCgh9rkbIkRFeBSfqiEr2LquONDUNu0LkJyaWFuIEJlaGxlbmRv
cmYgKExMTkwpIDxiZWhsZW5kb3JmMUBsbG5sLmdvdj6IXgQTEQIAHgUCRvL2QgIb
AwYLCQgHAwIDFQIDAxYCAQIeAQIXgAAKCRAKuemRxq9li3IUAJ91uoYT9XVsWrDB
RlPoqjfWsKznVQCfaK+mRj7TpSmR9aw77ll52PdV21y5Ag0ERvL2ShAIANbPczuS
yBi5+eEv9q/onCrQoFAx8bCiy6ATfk4n2mEQdJiM3AP5fhYGIiVitYX52uNf+JiT
AkBGDL/MsUHuT5xtNVQYbk6EaIeXwWk6WDUmNEq203tBsXp5iGQrsBK/p5tdrtB2
jWRRsTaz5MeDTH6ogPtMv0LSxyHyqGcc21b35vvt3x7TZwoyS21KvF4vQd1t0No3
nFbEO7pHtO47t0Xs5KvoATSvWNcfPw3KsJAN8omxoaEsjv/YQRBOi84s4LHgj5KE
qOpRPs41qfVGNcgPWys74BPXDo5mei6DJo+mppKd1gNEXEo1QXmHiU4Oe7mZllsf
psjVeZYxnZa5y08AAwUH/A0Pc9e4WsArzx5NCl5dvJ7biXs6+gMIW8I4cv+k+iVw
0vlJMumuPzRTC4CglVjYFiszPqw2FsRTDBnHfgrd1urLuli5OWe7unO6w2+v2wsp
Dnc4IvygiVqxB2c7k8/SuiES68ypMZwBOCpucqvMi1YDHtDQYiydC3RajUjAUAwU
8P+jPdZxthaGYiaZ0yMgb7ZznB/bTeAINGDnQ+uhvW9KtGBhyRShpI3NlNzix+08
rcNZ92jOXRNz8T9U0ykFCdGBm7iZlLNxGVU5u0N36HXRdWRXgLjNo3APqaglF+Rf
V9wf3RlNN64ISdiwPDe0wv5Bm6q1dlysnYqJGKQ4Uf6ISQQYEQIACQUCRvL2SgIb
DAAKCRAKuemRxq9liwm5AJ4gSyDQ6KvnvWwz/GITokfqEQscLACgyuSX45p3biIX
YMXfJucoJR6ZFKg=
=kHeM
-----END PGP PUBLIC KEY BLOCK-----
EOD

aur sync --noconfirm --noview --repo vond --root /tmp/local-repo zfs-utils

rsync -ai /tmp/local-repo/ aur@aur.vond.net:/opt/web-stack/aur/x86_64/

sleep 2

sudo pacman --noconfirm -Sy zfs-utils

aur sync --noconfirm --noview --repo vond --root /tmp/local-repo zfs-linux-lts || true

rsync -ai /tmp/local-repo/ aur@aur.vond.net:/opt/web-stack/aur/x86_64/

### END ZFS SECTION
