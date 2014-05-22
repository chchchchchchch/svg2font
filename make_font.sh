#!/bin/bash

  SVG=$1

  if [ -z "$SVG" ]; then

     echo "Please provide an svg file"
     echo "e.g. $0 input.svg"
     exit 0

  fi

  OUTPUTDIR=o
  TMPDIR=tmp
  BLANKFONT=i/utils/blank.sfd
  NAME=from_svg_directly

  ANSWER=y

  if [ -f ${OUTPUTDIR}/${NAME}.ttf ]; then
       echo "file does exist"
       read -p "overwrite ${OUTPUTDIR}/${NAME}.ttf? [y/n]" ANSWER
  fi


if [ $ANSWER = y ] ; then

# --------------------------------------------------------------------------- #
# MODIFY SVG BODY FOR EASIER PARSING
# --------------------------------------------------------------------------- #

      SVGHEADER=`tac $SVG | sed -n '/<\/metadata>/,$p' | tac`

      sed 's/ / \n/g' $SVG               | # SPACES TO LINEBREAKS
      sed 's/>/>\n/g'                    | # LINEBREAK AFTER END BRACKET
      sed -n '/<\/metadata>/,/<\/svg>/p' | 
      sed '1d;$d'                        | # SELECT BODY ONLY
      sed 's/<g/4Fgt7RfjIoPg7/g'         | # PLACEHOLDER FOR START BRACKET
      sed ':a;N;$!ba;s/\n/ /g'           | # REMOVE ALL NEW LINES
      sed 's/4Fgt7RfjIoPg7/\n<g/g'       | # RESTORE START BRACKET
      sed '/inkscape:label/s/<g/4Fgt7R/g'| # PLACEHOLDER FOR START BRACKET
      sed ':a;N;$!ba;s/\n/ /g'           | # REMOVE ALL NEW LINES
      sed 's/4Fgt7R/\n<g/g'              | # 
      grep  "inkscape:label"             | # LAYERS ONLY
      grep "<path"                       | # PATHS ONLY
      grep -v "XX_"                      | # REMOVE GUIDE LAYERS
      sed 's/display:none/display:inline/g' > ${SVG%%.*}.tmp

# --------------------------------------------------------------------------- #
# ONE SVG FOR EACH LAYER
# --------------------------------------------------------------------------- #

    for LAYER in `cat ${SVG%%.*}.tmp | \
                  sed 's/ /kjsdf73SAc/g' | \
                  grep -v "^$" | \
                  grep "inkscape:label"`
     do
        LAYER=`echo $LAYER | sed 's/kjsdf73SAc/ /g'`
        OUT=`echo $LAYER | sed 's/label/\nlabel/g' | \
             grep "^label" | cut -d "\"" -f 2`

        echo $SVGHEADER                       >  $TMPDIR/$OUT.svg
        echo $LAYER                           >> $TMPDIR/$OUT.svg
        echo "</svg>"                         >> $TMPDIR/$OUT.svg

        STYLE="style=\"fill:#000000;stroke:none;stroke-width:0px\""
        sed -i "s/style=\"[^\"]*\"/$STYLE/g" $TMPDIR/$OUT.svg         

    done

   # Font naming
   HUNAME=$NAME
   FAMILY=$NAME

   # Makes a backup of the blank font file
   cp $BLANKFONT ${BLANKFONT%%.*}_backup.sfd 

   # Changes font info
   sed -i "s/XXXX/$NAME/g" $BLANKFONT  
   sed -i "s/YYYY/$HUNAME/g" $BLANKFONT
   sed -i "s/ZZZZ/$FAMILY/g" $BLANKFONT

   clear; echo
   echo "Launching Ana and Ricardo's script"; echo
   # Launches Ana and Ricardo's script 
   # (takes a set of SVG files and puts them into a blank .sfd)

      ./svg2ttf-0.3.py
   
   # Reset the blank font to blank
   mv ${BLANKFONT%%.*}_backup.sfd $BLANKFONT 

   # Moves "output.ttf" into "o" folder
   mv output.ttf ${OUTPUTDIR}/${NAME}.ttf

   # Clean the "tmp" folder
   rm $TMPDIR/*.*
   rm ${SVG%%.*}.tmp


else
     exit 0;
fi



exit 0;




