import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Arabic-first type system - this app defaults to RTL/Arabic, so Cairo
/// (already the Arabic brand font on the web platform) is the PRIMARY
/// typeface for everything, not an afterthought bolted onto an English-first
/// scale. Inter (also already used on the web) is available for contexts
/// that are guaranteed pure-Latin content - prices, dates, stat numbers -
/// where its tighter, more geometric digits read slightly cleaner than
/// Cairo's. Arabic numerals rendered by Cairo still look correct and
/// on-brand on their own; Inter is a deliberate accent, not a requirement.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: display,
        headlineLarge: headline,
        titleLarge: title,
        bodyLarge: body,
        bodyMedium: bodySmall,
        labelSmall: caption,
      );

  // --- Named scale (display / headline / title / body / caption) ---

  static TextStyle get display => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get headline => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  static TextStyle get title => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get body => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // --- Latin accents (Inter) - use ONLY for guaranteed-Latin content ---

  static TextStyle get numberLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );

  static TextStyle get numberMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get latinCaption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
}
