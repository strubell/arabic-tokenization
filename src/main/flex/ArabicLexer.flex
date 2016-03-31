package edu.umass.cs.iesl.arabic_tok

import cc.factorie.util.JavaHashMap

/**
 *  A tokenizer for Arabic
 */

%%

%class ArabicLexer
%unicode
%type Object
%char
%caseless

%{


  var tokenizeSgml = false
  var tokenizeNewline = false
  var tokenizeWhitespace = false



  def this(in: Reader, tokSgml: Boolean = false, tokNewline: Boolean = false,
            tokWhitespace: Boolean = false) = {
    this(in)
    tokenizeSgml = tokSgml
    tokenizeNewline = tokNewline
    tokenizeWhitespace = tokWhitespace
  }

  def tok(): Object = tok(yytext())

  def tok(txt: String): Object = (txt, yychar, yylength)

  /* Uncomment below for useful debugging output */
  def printDebug(tok: String) = {println(s"$tok: |${yytext()}|")}//println(s"$tok: |${yytext()}|")

%}

/*separates ba, kalf, waw, lam  as prepositions ex. بالولد == ب الولد (with the boy)*/
PREPOSITION = (\u0628)|(\u0643)|(\u0644)|(\u0648)
/*min, ba3d, bayn, fi, ila, 3la, and m3a8*/
PREPOSITION2 = (\u0645)(\u0646)|(\u0628)(\u0639)(\u062F)|(\u0641)(\u064A)|[(\u0625)(\u0627)](\u0644)[(\u0649)(\u064A)]|(\u0639)(\u0644)[(\u0649)(\u064A)]|(\u0645)(\u0639)|(\u0628)(\u064A)(\u0646)
//separates pronons from stem
PRONOUN = ((\u064A)|(\u0643)|(\u0647)|(\u0647)(\u0627)|(\u0646)(\u0627)|(\u0647)(\u0645)(\u0627)|(\u0643)(\u0645)(\u0627)|(\u0643)(\u0645)|(\u0647)(\u0645))
//separates the al (the) from the begining of the word
DEFARTICLE = (\u0627)(\u0644)
//everything left after removing above clitics
STEM = {LETTER}+
LETTER = [\u0621-\u064a]

NEWLINE = \R

WHITESPACE = ([\p{Z}\t\f]|&nbsp;)+

/* Any non-space character. Sometimes, due to contextual restrictions above, some printed characters can slip through.
   It will probably be an error, but at least users will see them with this pattern. */
CATCHALL = \P{C}

%%

{PREPOSITION} / {STEM} {printDebug("PREPOSITION"); tok() }

{PREPOSITION2} / {STEM} {printDebug("PREPOSITION2"); tok() }

{PREPOSITION2} / {WHITESPACE} {printDebug("PREPOSITION2"); tok() }

{DEFARTICLE} / {STEM} {printDebug("DEFARTICLE"); tok() }

{PRONOUN} / {WHITESPACE} {printDebug("PRONOUN"); tok()}

{STEM} / {PRONOUN} { printDebug("STEM"); tok() }

{STEM} { printDebug("STEM"); tok() }

{NEWLINE} { printDebug("NEWLINE"); if (tokenizeWhitespace || tokenizeNewline) tok() else null }

{WHITESPACE} { printDebug("WHITESPACE"); if(tokenizeWhitespace) tok() else null}

{CATCHALL} { printDebug("CATCHALL"); tok() }

/* The only crap left here should be control characters, god forbid... throw them away */
. { printDebug("GARB"); null }

<<EOF>> { null }
