#!/bin/bash
#
# Blast DB Indexer Mini Pipeline for Galaxy
#
# Author:
# Jacob Israel Cervantes Luevano <jacobnix@gmail.com>
#
# Copyright (c) 2011 Jacob
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# input values
# $2 --> fasta filename
# $4 --> blast format: F->nucleotide, T->protein 
# $6 --> database filename
# $8 --> descriptor format (ncbi-gbk , other)

# cli variables 
shelp=$1
fasta=$2
blast_type_file=$4
blast_dbname=$6
fastadir=${fasta%/*}
fastafile=${fasta##*/}
tmpfasta="$fasta.tmp"
newfasta="$fastadir/new.$fastafile"
fastadesc=$8
galaxy_blastdb_loc="blastdb.loc"

# Usage
if [ "$shelp" = "-help" ]; then
 echo "||Blast DB Indexer Mini Pipeline for Galaxy. by Jacob @ Cinvestav Langebio MEXICO 2011"
 echo "||Allows to format blast databases, set galaxy format and create galaxy reference loc files"
 echo "||Usage: set_galaxy_blastdb.sh -help"
 echo "||Usage: set_galaxy_blastdb.sh -fasta filename -p T|F -n blastdb_name -fastadesc ncbi-gk|other"
 echo "||where:"
 echo "|| filename: fasta filename"
 echo "|| -p T if your database are protein sequences"
 echo "|| -p F if your database are nucleotide sequences"
 echo "|| -n blastdb_name set database filename for Galaxy Loc File"
 echo "|| -fastadesc ncbi-gk option if your fasta ID is like gi|gi-number|gb|accesión|locus"
 echo "|| -fastadesc other option"	
 exit 0
fi 

echo "--> Analyzing Sequences from $fastafile.."

if [ "$fastadesc" = "ncbi-gk" ]; then
 echo "--> Setting Galaxy Format.."
 python megablast-prepdb.py < $fasta > $newfasta
fi

if [ "$fastadesc" = "other" ]; then
 sed -e 's/>/>0|/g' $fasta > $tmpfasta
 echo "--> Setting Galaxy Format.."
 python megablast-prepdb.py < $tmpfasta > $newfasta
fi

cd $fastadir

echo "--> Format Reference Database.."
formatdb -i $newfasta -p $blast_type_file -n $blast_dbname

echo "--> Setting Up Megablast Galaxy Loc File.."
echo -e "$blast_dbname\t$blast_dbname\t$fastadir/$blast_dbname" > $fastadir/$galaxy_blastdb_loc

echo "--> Deleting temp files.."
rm $tmpfasta 2> /dev/null

echo "Done."
echo "Galaxy Blast Database are ready !!"
