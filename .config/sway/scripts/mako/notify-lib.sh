# This file is maintained as a literate file in
# 20240317205837-swaywm.org.
escape_pango_markup() {
    sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}
