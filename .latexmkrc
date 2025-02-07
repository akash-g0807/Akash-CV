# latexmkrc - Ensure Carlito is found automatically

# Use LuaLaTeX as the LaTeX engine
$pdflatex = 'lualatex %O %S';

# Enable nonstop mode
$pdflatex .= ' -interaction=nonstopmode';

# Suppress optional info for reproducibility
$pdflatex .= ' -pretex="\pdfvariable suppressoptionalinfo 512\relax"';

# Set output format to PDF
$pdf_mode = 1;

# Ensure Fontconfig knows about Carlito (using Nix-provided path)
$ENV{'OSFONTDIR'} = $ENV{'OSFONTDIR'} || "/run/current-system/sw/share/fonts";

# Force LuaLaTeX to update font cache before compilation
system("fc-cache -fv") == 0 or warn "Warning: Failed to refresh font cache\n";
system("luaotfload-tool --update") == 0 or warn "Warning: Failed to update LuaTeX font cache\n";

# Debugging output
print "Using OSFONTDIR: $ENV{'OSFONTDIR'}\n";

