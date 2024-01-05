;;; language-detection.el --- Automatic language detection from code snippets

;; Copyright (C) 2016 Andreas Jansson

;; Author: Andreas Jansson <andreas@jansson.me.uk>
;; URL: https://github.com/andreasjansson/language-detection.el
;; Package-Requires: ((emacs "24") (cl-lib "0.5"))
;; Version: 0.1.0

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Automatic programming language detection using pre-trained random
;; forest classifier.
;;
;; Supported languages:
;;
;;  * ada
;;  * awk
;;  * c
;;  * clojure
;;  * cpp
;;  * csharp
;;  * css
;;  * dart
;;  * delphi
;;  * emacslisp
;;  * erlang
;;  * fortran
;;  * fsharp
;;  * go
;;  * groovy
;;  * haskell
;;  * html
;;  * java
;;  * javascript
;;  * json
;;  * latex
;;  * lisp
;;  * lua
;;  * matlab
;;  * objc
;;  * perl
;;  * php
;;  * prolog
;;  * python
;;  * r
;;  * ruby
;;  * rust
;;  * scala
;;  * shell
;;  * smalltalk
;;  * sql
;;  * swift
;;  * visualbasic
;;  * xml
;;
;; Entrypoints:
;;
;;  * language-detection-buffer
;;    - When called interactively, prints the language of the current
;;      buffer to the echo area
;;    - When called non-interactively, returns the language of the
;;      current buffer
;;  * language-detection-string
;;    - Non-interactive function, returns the language of its argument

;;; Code:

(require 'cl-lib)

(defconst language-detection-token-pattern "\\([a-zA-Z0-9_]+\\|[^ a-zA-Z0-9_\n\t]+\\)")

;;;###autoload
(defun language-detection-buffer (&optional print-message)
  "Predict the programming language of the current buffer and output it to messages."
  (interactive "p")
  (let ((language (language-detection-string
                   (buffer-substring-no-properties (point-min) (point-max)))))
    (when print-message
      (message (format "%s" language)))
    language))

;;;###autoload
(defun language-detection-string (string)
  "Return the predicted programming language of STRING as a symbol."
  (let* ((tokens (language-detection-tokenize-string string))
         (freqs (language-detection-token-frequencies tokens)))
    (gethash (language-detection-forest-lookup freqs) language-detection-index-to-languages)))

(defun language-detection-forest-lookup (freqs)
  "Using the token frequencies FREQS, traverse the trees in the forest for predictions and return the majority vote."
  (let* ((table (make-hash-table :test 'equal))
         (predictions (cl-loop for tree in language-detection-forest
                               for (prediction prediction-proba) = (language-detection-tree-lookup tree freqs)
                               do (puthash prediction (+ (gethash prediction table 0) prediction-proba) table))))
    (cl-loop with max-count = 0
             with max-element = nil
             for prediction being the hash-key of table
             for count = (gethash prediction table)
             when (> count max-count)
             do (setq max-count count
                      max-element prediction)
             finally (return max-element))))

(defun language-detection-tree-lookup (tree freqs)
  "Traverse the decision tree TREE by comparing the token frequencies in FREQS to the thresholds at the nodes in the tree."
  (let ((node tree))
    (while (= (length node) 4)
      (if (<= (gethash (elt node 0) freqs 0) (elt node 1))
          (setq node (elt node 2))
        (setq node (elt node 3))))
    (list (elt node 0) (elt node 1))))

(defun language-detection-token-frequencies (tokens)
  "Create a bag-of-tokens by counting the frequencies of each token in TOKENS.  Frequencies are multiplied by 1000 to minimize number of trailing zeroes in forest blob."
  (cl-loop with table = (make-hash-table :test 'equal)
           with increment = (/ 1000.0 (length tokens))
           for token in tokens
           for current = (gethash token table 0)
           do (puthash token (+ increment current) table)
           finally (return table)))


(defun language-detection-tokenize-string (string)
  "Return a list of extracted tokens from STRING."
  (let* ((start-pos 0)
         (singles (cl-loop for match-pos = (string-match language-detection-token-pattern string start-pos)
                           while match-pos
                           for match = (match-string 1 string)
                           collect match
                           do (setf start-pos (+ match-pos (length match)))))
         (pairs (cl-loop for (a b) on singles while b
                         collect (format "%s %s" a b))))
    (cl-loop for token in (append singles pairs)
             collect (gethash token language-detection-tokens-to-index))))

(defun language-detection-alist-to-hashmap (alist)
  "Return a hashmap from ALIST."
  (let ((table (make-hash-table :test 'equal)))
    (cl-loop for (k . v) in alist
             do (puthash k v table))
    table))

;; BEGIN AUTO-GENERATED CODE

(defconst language-detection-tokens-to-index (language-detection-alist-to-hashmap '(("Math ." . 3585) ("content" . 4939) (":- X" . 2462) (". AddWithValue" . 1464) ("AS" . 3045) ("@ IBAction" . 3011) ("IBAction func" . 3431) ("{ padding" . 7580) ("names =" . 6215) ("[] byte" . 4223) ("]; then" . 4348) ("%)" . 297) ("nbsp" . 6224) ("with |" . 7434) (") Dim" . 834) (": expected" . 2380) ("A |" . 3035) ("forward" . 5446) ("hObject ," . 5582) ("xsd" . 7484) ("*( exp" . 1045) ("hook" . 5619) ("init ];" . 5792) ("lisp /" . 6014) ("line =~" . 6003) ("TBitmap" . 3945) ("}}," . 7764) ("score" . 6828) ("\"$" . 107) ("- transform" . 1375) (", 9" . 1115) ("\") end" . 119) ("As Double" . 3082) ("mode -" . 6150) ("<>" . 2746) ("android ." . 4537) ("} impl" . 7701) ("( spec" . 638) ("text_field" . 7162) ("\"]]" . 212) ("vector <" . 7365) ("EXIT" . 3285) ("function (){" . 5485) ("Assigned" . 3090) ("ruby -" . 6773) ("TextView android" . 3984) ("17" . 2068) (">>>" . 2989) ("endl" . 5239) ("( eval" . 548) ("R =" . 3799) ("; };" . 2617) ("UTF" . 4050) ("> ///" . 2946) ("expect" . 5307) ("M ," . 3568) (". Handle" . 1495) ("</ html" . 2717) ("Server" . 3878) ("HashMap" . 3414) ("X |" . 4124) ("any" . 4557) ("\" func" . 73) ("view addSubview" . 7375) ("strlen" . 7029) (". Item" . 1502) ("mark" . 6101) ("n =" . 6196) ("path" . 6449) ("exit 1" . 5302) ("String []" . 3915) (". objects" . 1685) ("CGPoint (" . 3144) ("end function" . 5226) ("; for" . 2567) ("/ 1" . 1786) ("tbody" . 7121) ("addSubview (" . 4494) (". position" . 1702) ("fa (" . 5335) ("vendor" . 7366) ("cl" . 4849) ("real (" . 6661) ("] [," . 4293) (": 5" . 2299) ("cmd" . 4874) ("=\"<? php" . 2883) ("& &" . 314) (";&#" . 2623) ("dev" . 5071) ("/ rack" . 1855) ("-[" . 1428) ("rand" . 6639) ("Table" . 3964) (". Message" . 1508) ("= None" . 2781) ("| html" . 7647) ("asParser ," . 4619) ("[ j" . 4187) (": layout_height" . 2403) ("( remove" . 623) (". eclipse" . 1612) ("</ body" . 2712) ("partial" . 6442) ("li" . 5983) ("graphicx" . 5558) ("rw" . 6787) ("Just" . 3523) ("share" . 6903) ("'\"" . 365) ("mnesia" . 6145) ("localhost" . 6034) ("binary" . 4705) ("Byte" . 3128) ("100 %;" . 2030) ("/ repository" . 1859) ("), ." . 943) ("Write" . 4109) ("templates" . 7136) ("id ." . 5677) ("ierr" . 5690) (":-" . 2461) (") import" . 870) ("viewDidLoad ()" . 7377) ("DelegatingMethodAccessorImpl ." . 3255) ("| l" . 7648) ("\" }," . 100) ("fprintf (" . 5451) (") If" . 841) ("defining" . 5044) ("current_user ." . 4985) ("/ gcc" . 1830) ("-> a" . 1411) ("= io" . 2817) ("awk :" . 4659) ("case _" . 4800) ("<%= f" . 2697) ("$(\"#" . 279) ("golang" . 5544) ("\"\"," . 104) ("char *)" . 4834) ("Test" . 3971) ("3L" . 2175) ("coll" . 4881) ("active_support" . 4468) ("}'" . 7729) ("show :" . 6912) ("a (" . 4416) ("erts" . 5272) (". util" . 1745) ("| 1" . 7627) ("ARGV [" . 3044) ("warnings ;" . 7397) ("anonfun $" . 4552) ("x y" . 7465) ("$('#" . 282) (". getElementById" . 1631) ("= {}" . 2847) ("<- as" . 2702) ("deriving" . 5065) ("arising" . 4596) ("require \"" . 6712) ("subtype" . 7056) ("bash" . 4682) (";\">" . 2619) ("*/ public" . 1060) ("equal ?" . 5250) ("{ FS" . 7528) ("Net" . 3685) ("iterator" . 5880) ("< std" . 2673) ("As Byte" . 3081) ("Future [" . 3378) ("\" >>" . 46) ("if ((" . 5696) ("< label" . 2660) ("Width =\"" . 4104) ("( id" . 568) ("\"?>" . 199) ("Classes ," . 3184) ("0 ;" . 1919) ("+ '" . 1064) ("Sub" . 3921) ("t match" . 7095) ("2016 -" . 2124) (". bounds" . 1575) (")" . 791) ("()." . 728) ("X ,[" . 4121) ("( message" . 594) ("tableView :" . 7109) (". height" . 1641) ("3 4" . 2156) ("springframework" . 6952) ("Qt4" . 3792) ("document }" . 5133) ("Future" . 3377) ("FUNCTION" . 3336) ("borrow" . 4729) (". st" . 1728) ("( c" . 515) ("(*)" . 740) ("r *" . 6623) (", R" . 1145) ("csv" . 4978) ("- bottom" . 1275) ("''," . 369) ("bufio" . 4753) ("forKey :@\"" . 5427) ("MsgBox" . 3610) ("new {" . 6243) ("-->" . 1395) ("For Each" . 3360) ("]; [" . 4342) ("( Tail" . 497) ("UITableView ," . 4036) ("\\==" . 4275) ("input $" . 5800) ("; PROCEDURE" . 2543) (". 2" . 1451) ("value" . 7343) (": 14" . 2286) ("+ 01" . 1067) ("- transition" . 1376) ("0 .." . 1914) ("deps" . 5060) ("2 2" . 2098) ("frame :" . 5458) ("minor" . 6143) ("boolean" . 4719) ("28" . 2138) ("w :" . 7388) ("b :=" . 4668) ("( err" . 547) ("log" . 6040) ("Void in" . 4088) ("with get" . 7432) ("printStackTrace ();" . 6535) ("1 do" . 2015) ("\" 0" . 38) ("scene" . 6818) ("1 ," . 1995) ("YES" . 4145) ("current -" . 4983) ("android =\"" . 4539) ("SSL" . 3859) ("u8" . 7277) (")];" . 1020) ("DOCTYPE" . 3238) ("fn new" . 5406) ("75" . 2237) ("() =" . 705) ("\"\\" . 201) ("-> Option" . 1406) ("list" . 6015) ("renewcommand {\\" . 6698) ("parent" . 6439) ("=\" application" . 2856) ("valueForKey" . 7350) ("// TODO" . 1889) ("replace" . 6703) ("failed" . 5343) ("attr (\"" . 4646) ("=~" . 2936) ("As Integer" . 3085) (") :" . 818) ("err !=" . 5261) ("< br" . 2646) ("> 0" . 2947) ("< property" . 2670) ("hide" . 5612) ("cpan" . 4963) (":: [" . 2476) ("} ]" . 7687) ("match_parent \"" . 6108) ("anonfun" . 4551) ("init /" . 5791) ("100 ." . 2032) ("nil )" . 6261) ("collapse" . 4882) ("q" . 6613) ("- lock" . 1327) ("project ." . 6570) ("Free" . 3369) ("command -" . 4899) ("in `" . 5759) ("else (" . 5193) ("( Unknown" . 498) ("FSharp ." . 3335) ("( defun" . 538) ("(" . 429) ("ggplot" . 5526) (". RT" . 1524) ("private type" . 6556) ("cos (" . 4955) ("import UIKit" . 5740) ("else echo" . 5196) (". org" . 1687) ("FILE *" . 3328) ("pygame ." . 6609) ("put (" . 6598) ("=\"@ drawable" . 2885) ("script >" . 6831) ("tempAnimal at" . 7131) ("( [" . 502) ("tr" . 7231) ("factor" . 5338) ("tab -" . 7100) ("]). -" . 4321) ("\" data" . 64) (". Lines" . 1506) ("TButton" . 3946) ("async" . 4627) ("( 11" . 437) ("( set" . 633) ("[&" . 4204) ("WriteLine" . 4110) ("' gem" . 357) (", ?" . 1117) ("); printf" . 1004) ("akka ." . 4506) ("<<" . 2739) ("3 )." . 2147) (") =>" . 828) ("Classes" . 3183) ("dart ';" . 5001) ("text >" . 7158) ("\" echo" . 67) ("warn" . 7394) ("import android" . 5741) ("for k" . 5422) ("-> '" . 1401) ("from django" . 5464) ("Next" . 3691) ("disp" . 5089) ("console ." . 4927) ("..$ :" . 1768) ("GO" . 3387) ("/ Python" . 1797) ("_POST" . 4390) ("{\"" . 7606) ("on" . 6353) (". apache" . 1564) ("; then" . 2600) ("up" . 7297) ("rust" . 6782) ("while read" . 7415) ("o )" . 6329) ("111" . 2044) ("dt" . 5150) ("expression" . 5312) ("Eq" . 3304) ("( Socket" . 493) ("! @" . 3) ("accept" . 4455) (". setText" . 1721) ("ls" . 6056) ("56" . 2216) ("has" . 5588) ("as $" . 4613) ("/ polymer" . 1852) ("setq" . 6897) ("Async ." . 3093) ("- width" . 1384) ("/ 3" . 1793) ("\\@" . 4276) ("ls -" . 6058) ("-> case" . 1413) ("- frame" . 1307) ("func" . 5472) ("/ etc" . 1828) ("As EventArgs" . 3083) ("main $" . 6075) ("] =" . 4288) (". id" . 1648) (": addEventListener" . 2354) (". addBody" . 1558) ("(@\"%@\"," . 773) ("] ==" . 4289) ("echo -" . 5178) ("\\=" . 4274) ("the first" . 7171) ("nullable :" . 6316) ("Buffer" . 3118) ("& (" . 315) ("A ]" . 3034) ("rails /" . 6635) ("str (" . 6998) ("/ jquery" . 1837) ("DESC" . 3234) (":= make" . 2505) ("pdflatex" . 6454) ("strict ;" . 7008) ("Application ." . 3070) ("= case" . 2803) (": 7" . 2303) ("( list" . 585) ("dired -" . 5088) ("println (" . 6548) (", cellForRowAtIndexPath" . 1172) ("<? xml" . 2750) ("deallocate (" . 5027) ("native" . 6218) ("typechecker" . 7263) ("\\ textwidth" . 4265) ("( TForm" . 496) ("( Object" . 480) ("- 08" . 1251) ("cout <<\"" . 4961) ("IN" . 3444) ("} close" . 7691) ("- size" . 1364) ("- test" . 1371) ("\";" . 178) ("each |" . 5166) ("extern crate" . 5321) ("3 3" . 2155) ("Log ." . 3563) ("are" . 4583) ("junit" . 5910) ("-( void" . 1390) (":/" . 2464) ("{ panic" . 7581) ("} type" . 7716) ("for =\"" . 5415) ("i =" . 5662) ("juan" . 5908) ("border =\"" . 4728) ("++ show" . 1070) ("\" -" . 33) ("strict" . 7007) ("})" . 7731) ("' T" . 349) ("Of String" . 3719) (", DIMENSION" . 1125) ("$ _SESSION" . 255) ("9 ." . 2253) ("a ></" . 4427) ("plot" . 6490) ("belongs_to :" . 4702) ("isEqualToString :@\"" . 5867) ("end %>" . 5214) ("program main" . 6567) (". end" . 1614) ("- point" . 1346) ("Seq [" . 3875) ("range 1" . 6645) ("() {" . 719) (". performWithDelay" . 1694) ("( if" . 569) ("11 )" . 2040) ("(- n" . 749) ("pkg /" . 6483) ("shift ;" . 6908) ("54" . 2214) ("widget" . 7417) ("weight :" . 7407) ("7" . 2232) ("Graphics" . 3397) ("list1" . 6021) ("texmf" . 7147) (". RestFn" . 1527) ("<' T" . 2699) ("unless" . 7289) ("TextView" . 3983) (". Text_IO" . 1534) ("FALSE ," . 3326) ("new (" . 6231) ("X2" . 4127) ("_ )" . 4370) ("< p" . 2667) ("IBAction )" . 3430) ("# print" . 229) ("{ article" . 7539) ("numel" . 6321) (", P" . 1143) ("( a" . 504) ("then ((" . 7177) ("_ |" . 4382) ("== null" . 2910) ("];" . 4338) (". then" . 1739) ("last" . 5942) (": T" . 2332) ("2001" . 2111) ("allocatable ::" . 4521) ("H2" . 3408) ("( dart" . 531) ("factory" . 5340) ("google" . 5545) ("help :" . 5603) ("entry" . 5241) ("First" . 3353) ("php if" . 6474) ("- hook" . 1312) ("perl5 /" . 6462) ("\"]; [" . 209) (". 4" . 1453) ("user =" . 7317) (": 12" . 2284) ("/\\" . 1898) ("://" . 2466) ("ATOM" . 3047) ("*, \"" . 1056) ("is N" . 5854) ("' Chapter" . 341) ("0l0" . 1971) ("sexp" . 6898) ("local" . 6031) ("backgroundColor =" . 4678) ("{ match" . 7575) ("(:, 1" . 761) ("(\"@" . 669) ("<$>" . 2693) ("argument" . 4592) ("0 &" . 1903) ("destructor" . 5070) (",," . 1228) ("make -" . 6085) ("ones" . 6360) ("a ." . 4421) ("eval -" . 5280) ("try {" . 7253) ("{ background" . 7540) ("pid" . 6481) ("IBOutlet weak" . 3434) ("Println (" . 3769) ("=\"<?" . 2882) (". out" . 1690) ("IN (" . 3445) ("of {" . 6348) ("objectForKey :@\"" . 6338) ("( frame" . 557) ("Gtk" . 3402) ("is record" . 5862) ("( handles" . 565) ("!!" . 7) ("Add ('" . 3059) ("t /" . 7093) (". clj" . 1581) ("assets" . 4625) ("author" . 4650) ("exit (" . 5300) ("= match" . 2822) ("Bool {" . 3112) ("c (" . 4769) ("i );" . 5651) ("key (" . 5919) ("- -" . 1241) ("=`" . 2934) ("> 2" . 2949) ("Memo1" . 3589) ("</ paper" . 2724) ("file1" . 5374) ("concurrent ." . 4916) ("--" . 1391) ("5 ." . 2202) ("document )." . 5131) ("';" . 407) ("{ noreply" . 7577) ("foreach (" . 5430) ("timer" . 7200) (": false" . 2381) ("} case" . 7688) ("screen" . 6829) ("( Item" . 467) ("ngx ." . 6259) ("dependencies ." . 5057) ("main" . 6074) ("100 ," . 2031) ("( cond" . 524) ("Array [" . 3075) ("where import" . 7412) ("[ warn" . 4194) ("file -" . 5370) ("window" . 7425) ("navbar" . 6221) ("Put (" . 3785) (")) +" . 910) ("=\"{" . 2889) ("msg" . 6170) ("= <" . 2769) ("$ file" . 260) ("] {" . 4307) ("mode )" . 6149) (")))" . 915) ("= false" . 2811) ("retain )" . 6731) ("&&" . 324) ("public int" . 6586) ("[$" . 4201) ("}); });" . 7736) ("texmf -" . 7148) (", nil" . 1199) ("Async" . 3092) ("1 (" . 1985) ("<:" . 2738) ("string []" . 7021) ("println" . 6544) ("https ://" . 5643) ("; print" . 2586) ("13" . 2055) ("; var" . 2607) ("assoc" . 4626) ("rep" . 6699) ("\\ subsection" . 4261) ("for i" . 5420) ("Content -" . 3208) ("] as" . 4296) ("\"}" . 216) (". Printf" . 1520) ("} override" . 7705) ("- USER" . 1266) ("' my" . 358) ("]);" . 4324) ("?)" . 2999) ("| (" . 7625) ("L =" . 3532) (": isolate" . 2401) ("deallocate" . 5026) ("addMorph :" . 4490) ("subplot (" . 7051) ("local function" . 6033) ("indexPath :" . 5782) ("x =" . 7461) ("forKey" . 5425) ("= [\"" . 2794) ("))))" . 917) ("NSLog (@\"" . 3653) ("number" . 6320) ("T" . 3931) ("{ itemize" . 7570) ("], [" . 4330) ("b ," . 4665) ("spawn" . 6945) ("private :" . 6552) ("/ 5" . 1795) ("As Object" . 3087) (". text" . 1738) ("items" . 5878) ("0000000" . 1941) ("P" . 3735) ("iter" . 5879) ("ch" . 4827) ("3 |" . 2160) ("=\" UTF" . 2854) ("i As" . 5663) ("pas" . 6444) ("n 1" . 6194) ("; @" . 2541) ("] src" . 4305) ("instanceVariableNames" . 5810) ("width" . 7419) ("G ," . 3380) ("Ada" . 3054) ("* sin" . 1039) ("objects" . 6339) ("generic" . 5508) ("'] =" . 419) ("real ," . 6663) (") \\" . 848) ("name \":" . 6201) ("( New" . 479) ("This is" . 3994) (", file" . 1184) ("php echo" . 6473) ("( data" . 532) ("sender As" . 6868) ("content =\"" . 4940) ("rubies /" . 6771) ("rs" . 6767) ("( '" . 432) ("\\ tex" . 4263) ("with Ada" . 7431) ("bundle" . 4757) ("addEventListener (" . 4487) ("SizeOf (" . 3891) ("js :" . 5903) ("Checked" . 3181) ("=\"@ string" . 2886) ("character" . 4838) (": b" . 2366) ("( nil" . 604) ("yourself" . 7503) (", int" . 1190) ("info" . 5784) ("save -" . 6803) ("( \"" . 430) ("height =\"" . 5600) ("py" . 6606) ("PACKAGE" . 3737) (")," . 939) ("-> m" . 1419) (": aString" . 2349) ("($ 0" . 674) ("font -" . 5409) ("i ;" . 5659) ("center ;" . 4822) ("Closure" . 3193) ("server" . 6877) ("female (" . 5357) ("http -" . 5639) ("% v" . 293) ("\"); $" . 135) ("$ query" . 264) (":: String" . 2475) ("| 5" . 7631) ("); $" . 980) ("){" . 1023) ("point" . 6503) ("Seq ." . 3874) ("gen_tcp :" . 5507) ("9 ," . 2252) (". catalina" . 1579) ("_ ." . 4375) ("\" t" . 92) ("CL" . 3150) ("168 ." . 2067) ("- path" . 1345) ("|]" . 7663) ("/ go" . 1833) (":= grid" . 2503) ("of" . 6342) (") #" . 794) ("\",\"" . 155) (". random" . 1709) ("do local" . 5120) ("overriding" . 6405) ("5" . 2199) ("nn ." . 6275) ("wait" . 7392) ("If Next" . 3468) ("cut" . 4988) ("- decoration" . 1289) ("else" . 5192) ("=$ 1" . 2893) ("]=" . 4350) ("let !" . 5973) ("getString" . 5521) (". Cells" . 1470) ("\" \"" . 24) ("do print" . 5121) ("0 ])." . 1926) ("jQuery" . 5888) ("3 0" . 2153) ("_ ->" . 4374) ("{ }" . 7605) ("set -" . 6886) ("[ UIView" . 4175) ("bin /" . 4704) (". a" . 1555) (": &'" . 2267) (": 10" . 2281) ("\" fmt" . 72) ("client" . 4861) ("127" . 2053) ("Value =\"" . 4074) ("use" . 7305) (":= self" . 2510) ("fo" . 5407) ("; self" . 2593) ("const int" . 4931) ("cin" . 4847) ("span class" . 6942) ("ERROR ]" . 3283) (". 6" . 1456) ("%@\"," . 308) ("at System" . 4634) ("xsd :" . 7485) ("48" . 2195) ("; 0" . 2537) (". 1427" . 1449) ("{ int" . 7568) ("dart '" . 5000) ("13 :" . 2057) ("forms" . 5445) ("unit =" . 7288) ("created" . 4969) ("24" . 2131) ("- gradient" . 1310) ("( funcall" . 559) ("? x" . 2998) ("idx" . 5689) ("Jun" . 3521) ("xmlns ='" . 7477) ("width ," . 7420) ("- local" . 1326) ("dir" . 5084) ("0x00" . 1978) ("$ do" . 258) ("DEFAULT" . 3233) ("= T" . 2785) (") ;" . 822) ("h1" . 5577) ("gem" . 5498) (", FMX" . 1130) (")^" . 1021) ("(&" . 682) ("local /" . 6032) ("aValue" . 4443) ("/ css" . 1820) ("media" . 6123) ("Int ->" . 3484) ("image" . 5716) ("go func" . 5543) ("SET @" . 3852) ("newText" . 6246) ("- 3" . 1260) ("']);" . 421) ("main =" . 6080) ("{ fn" . 7559) ("5 ," . 2201) ("Lines ." . 3553) ("']; $" . 424) ("javax ." . 5896) ("TForm1 ." . 3952) ("}" . 7665) ("fun" . 5467) ("nextPutAll" . 6254) ("| 3" . 7629) ("fclose (" . 5354) ("& \\\\" . 319) ("= {" . 2846) ("x (" . 7450) ("ERROR" . 3281) ("FormCreate (" . 3364) (": {" . 2445) ("; override" . 2582) ("CASE" . 3140) ("( conj" . 525) (", NA" . 1140) ("qw (" . 6620) ("temp" . 7127) ("unwrap ();" . 7296) ("set" . 6883) ("awt" . 4660) ("))+" . 925) ("]. ]." . 4334) ("]] =" . 4354) ("repository /" . 6706) (". frame" . 1628) ("case class" . 4801) ("mail" . 6073) (", 1L" . 1100) ("decoration" . 5032) ("\"]=> string" . 211) ("texlive" . 7145) ("has_many" . 5589) (".\"" . 1757) ("10 :" . 2028) ("org" . 6380) ("text :" . 7155) ("AbstractCallSite" . 3048) (",*)" . 1227) (", 3" . 1104) ("=\" width" . 2871) ("db ->" . 5020) ("*) malloc" . 1049) ("os ." . 6389) ("loop ;" . 6050) ("^ self" . 4366) ("net ." . 6228) ("</ head" . 2716) ("/ ardnew" . 1811) ("textField" . 7160) ("comment :" . 4902) ("Sender :" . 3871) ("defining Unicode" . 5045) ("SQL" . 3857) ("? creep" . 2996) (". Top" . 1536) ("x86_64 -" . 7470) (": CGRectMake" . 2314) ("\"] [" . 205) ("'; $" . 408) ("imshow (" . 5752) ("internal ." . 5837) ("x ;" . 7459) ("IntPtr" . 3489) (",[ X" . 1234) ("Unicode" . 4054) (": polymer" . 2415) (", in" . 1189) ("include <" . 5771) ("save" . 6802) ("foreground" . 5433) ("* pi" . 1038) ("not found" . 6296) ("log (\"" . 6043) ("} pub" . 7710) ("\" Then" . 53) ("NSDictionary" . 3642) ("if not" . 5706) ("( save" . 629) ("b ." . 4667) ("/$" . 1881) ("kind" . 5923) ("1 to" . 2019) ("/ tmp" . 1874) ("\" os" . 87) ("ls )" . 6057) ("location" . 6036) ("packages \\" . 6419) ("Drawing" . 3266) (": absolute" . 2351) ("^" . 4364) ("7 )" . 2233) ("endl ;" . 5240) ("artifactId" . 4609) ("Printf (\"%" . 3767) ("center" . 4820) ("hidden ;" . 5610) ("cond [(" . 4919) ("j <" . 5886) ("' end" . 355) ("str ," . 7000) ("e )" . 5155) ("double precision" . 5143) (", k" . 1193) ("lstlisting" . 6062) (". Open" . 1517) ("(\\" . 786) ("Any" . 3066) ("' a" . 350) ("i ]." . 5666) ("- get" . 1309) (": 3" . 2297) ("int main" . 5820) ("kind =" . 5924) ("add :" . 4481) ("so" . 6929) (":= 0" . 2493) ("1px solid" . 2080) ("gsub" . 5571) ("- in" . 1315) ("rm" . 6752) ("} def" . 7692) ("err ." . 5263) ("Integer" . 3492) ("interactive" . 5831) ("Mat" . 3583) ("47" . 2194) ("member" . 6124) ("</ ul" . 2734) (") then" . 887) ("ON" . 3708) ("
(defconst language-detection-index-to-languages (language-detection-alist-to-hashmap '((0 . ada) (1 . awk) (2 . c) (3 . clojure) (4 . cpp) (5 . csharp) (6 . css) (7 . dart) (8 . delphi) (9 . emacslisp) (10 . erlang) (11 . fortran) (12 . fsharp) (13 . go) (14 . groovy) (15 . haskell) (16 . html) (17 . java) (18 . javascript) (19 . json) (20 . latex) (21 . lisp) (22 . lua) (23 . matlab) (24 . objc) (25 . perl) (26 . php) (27 . prolog) (28 . python) (29 . r) (30 . ruby) (31 . rust) (32 . scala) (33 . shell) (34 . smalltalk) (35 . sql) (36 . swift) (37 . visualbasic) (38 . xml))))

;; END AUTO-GENERATED CODE

(provide 'language-detection)

;;; language-detection.el ends here