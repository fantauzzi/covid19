#!/bin/bash
set -e

cp customise_bash.sh ~
mkdir -p ~/.local/bin
mkdir -p ~/Downloads
cd ~/Downloads || exit

echo "Installing needed Ubuntu packages"
sudo add-apt-repository -y universe
sudo apt update
sudo apt install -y build-essential
sudo apt install -y autoconf
sudo apt install -y zlib1g-dev libffi-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev libncurses-dev tk-dev
# sudo apt install -y tabix
sudo apt install -y python3-pip
echo "Updating Ubuntu setup"
sudo apt update
sudo apt upgrade -y

# unzip
echo "Installing unzip"
sudo apt install -y unzip

# bzip2
# sudo apt install -y bzip2

#  SRA Toolkit https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
echo "Installing the SRA Toolkit"
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
tar xvf sratoolkit.current-ubuntu64.tar.gz
mv sratoolkit.3.1.1-ubuntu64 ~/.local
cd ~/.local/bin || exit
ln -s ~/.local/sratoolkit.3.1.1-ubuntu64/bin/* .
cd || exit
mkdir -p ~/.cache/sra-toolkit

# seqkit
echo "Installing seqkit"
sudo apt update
sudo apt install -y seqkit

# pbzip2
# sudo apt install -y pbzip2

# NCBI datasets
echo "Installing NCBI datasets"
cd ~/Downloads || exit
wget https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets
mv datasets ~/.local/bin
chmod a+x ~/.local/bin/datasets

# samtools
echo "Installing samtools"
sudo apt install -y samtools

cd ~/Downloads/
git clone https://github.com/samtools/htslib.git
cd htslib
git submodule update --init --recursive
autoreconf -i
./configure
make
make prefix=/home/fanta/.local/htslib install
cd ~/.local/bin
ln -s ../htslib/bin/* .

# bowtie2
echo "Installing bowtie2"
sudo apt install -y bowtie2

# bcftools
echo "Installing bcftools"
sudo apt install -y bcftools

# spades 4
echo "Installing SPAdes 4"
cd ~/Downloads/
wget https://github.com/ablab/spades/releases/download/v4.0.0/SPAdes-4.0.0-Linux.tar.gz
tar xvf SPAdes-4.0.0-Linux.tar.gz
mv SPAdes-4.0.0-Linux ~/.local/
cd ~/.local/bin
ln -s ../SPAdes-4.0.0-Linux/bin/* .

cd ~/.local
git clone https://github.com/lh3/gfatools
cd gfatools
make
cd ~/.local/bin
ln -s ../gfatools/gfatools .

cd ~/.local
git clone https://github.com/lh3/seqtk.git
cd seqtk
make
cd ~/.local/bin
ln -s ../seqtk/seqtk .

echo "Installing Python stuff"
cd
curl https://pyenv.run | bash
#
export PATH="$PATH:/home/fanta/.pyenv/bin"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
#
pyenv install 3.12.3
pyenv virtualenv 3.12.3 default
pyenv activate default
pyenv virtualenvs
pip install --upgrade pip
pip install snakemake
pip install tqdm
pip install pandas
pip install matplotlib

# Note: for this version of parallel to be invoked instead of the system-wide one, ~/.local/bin must be at the
# beginning of the PATH
cd ~/Downloads/
wget https://ftpmirror.gnu.org/parallel/parallel-latest.tar.bz2
tar xvf parallel-latest.tar.bz2
cd parallel-20240822
./configure --prefix=$HOME/.local
make
make install

# Next up installs (also) a recent version of tbl2asn, needed by prokka
sudo apt install -y ncbi-tools-bin

# prokka needs ncbi-tools-bin and a recent version of parallel, see above
cd ~/.local
sudo apt install -y libdatetime-perl libxml-simple-perl libdigest-md5-perl git default-jre bioperl
sudo apt install cpanminus
echo "yes" | sudo cpan Bio::Perl
git clone https://github.com/tseemann/prokka.git $HOME/.local/prokka
$HOME/.local/prokka/bin/prokka --setupdb
cd ~/.local/bin
ln -s ../prokka/bin/* .


echo "************************************************"
echo "* Remember to configure SRA with vdb-config -i *"
echo "************************************************"
