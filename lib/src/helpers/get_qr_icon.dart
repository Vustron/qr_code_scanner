import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

IconData getQRContentIcon(String value) {
  final Uri? uri = Uri.tryParse(value);

  if (uri != null && uri.hasScheme) {
    // Social Media
    if (value.contains('facebook.com') || value.contains('fb.me')) {
      return FluentIcons.people_24_filled;
    }
    if (value.contains('instagram.com')) {
      return FluentIcons.image_24_filled;
    }
    if (value.contains('twitter.com') || value.contains('x.com')) {
      return FluentIcons.comment_24_filled;
    }
    if (value.contains('linkedin.com')) {
      return FluentIcons.briefcase_24_filled;
    }
    if (value.contains('tiktok.com')) {
      return FluentIcons.video_clip_24_filled;
    }

    // Messaging
    if (value.contains('messenger.com')) {
      return FluentIcons.chat_24_filled;
    }
    if (value.contains('wa.me') || value.contains('whatsapp.com')) {
      return FluentIcons.chat_24_filled;
    }
    if (value.contains('t.me') || value.contains('telegram.me')) {
      return FluentIcons.send_24_filled;
    }

    // Video/Streaming
    if (value.contains('youtube.com') || value.contains('youtu.be')) {
      return FluentIcons.video_24_filled;
    }
    if (value.contains('netflix.com')) {
      return FluentIcons.tv_24_filled;
    }
    if (value.contains('spotify.com')) {
      return FluentIcons.music_note_2_24_filled;
    }

    // Shopping
    if (value.contains('amazon.com')) {
      return FluentIcons.cart_24_filled;
    }
    if (value.contains('shopee')) {
      return FluentIcons.shopping_bag_24_filled;
    }

    // Productivity
    if (value.contains('drive.google.com')) {
      return FluentIcons.folder_24_filled;
    }
    if (value.contains('docs.google.com')) {
      return FluentIcons.document_24_filled;
    }
    if (value.contains('sheets.google.com')) {
      return FluentIcons.table_24_filled;
    }
    if (value.contains('meet.google.com')) {
      return FluentIcons.video_person_24_filled;
    }

    // Code Repositories
    if (value.contains('github.com')) {
      return FluentIcons.code_24_filled;
    }
    if (value.contains('gitlab.com')) {
      return FluentIcons.code_circle_24_filled;
    }

    // Search Engines
    if (value.contains('google.com')) {
      return FluentIcons.search_24_filled;
    }
    if (value.contains('bing.com')) {
      return FluentIcons.search_square_24_filled;
    }

    // Payment
    if (value.contains('paypal.com')) {
      return FluentIcons.payment_24_filled;
    }

    // File types
    if (value.contains('.pdf')) {
      return FluentIcons.document_pdf_24_filled;
    }
    if (value.contains('.doc') || value.contains('.docx')) {
      return FluentIcons.document_text_24_filled;
    }
    if (value.contains('.xls') || value.contains('.xlsx')) {
      return FluentIcons.table_simple_24_filled;
    }

    // Communication
    if (value.contains('maps.google.com') || value.contains('goo.gl/maps')) {
      return FluentIcons.map_24_filled;
    }
    if (value.contains('mailto:')) {
      return FluentIcons.mail_24_filled;
    }
    if (value.contains('tel:')) {
      return FluentIcons.phone_24_filled;
    }
    if (value.contains('sms:')) {
      return FluentIcons.chat_24_filled;
    }

    return FluentIcons.link_24_filled;
  }

  if (value.startsWith('BEGIN:VCARD')) {
    return FluentIcons.person_24_filled;
  }
  if (RegExp(r'^[0-9]+$').hasMatch(value)) {
    return FluentIcons.number_symbol_24_filled;
  }
  if (RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
      .hasMatch(value)) {
    return FluentIcons.mail_24_filled;
  }

  return FluentIcons.document_24_filled;
}
