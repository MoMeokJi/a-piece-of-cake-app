import 'package:cake/ui/style/color_config.dart';
import 'package:cake/utils/dialog/inactive_dialog.dart';
import 'package:cake/utils/dialog/update_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DialogUtils {
  static Future<void> showUpdateDialog({
    required BuildContext context,
    required VoidCallback onUpdatePressed,
    VoidCallback? onLaterPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(
        onUpdatePressed: onUpdatePressed,
        onLaterPressed: onLaterPressed,
      ),
    );
  }

  static Future<void> showInactivityDialog({
    required BuildContext context,
    required VoidCallback onConfirmed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InactivityDialog(onConfirmed: onConfirmed),
    );
  }

  static Future<bool?> showDeleteConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(fontSize: 18, color: ColorConfig.black),
        ),
        content: Text(
          content,
          style: TextStyle(fontSize: 16, color: ColorConfig.gray1),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => context.pop(false),
            child: Text(
              '취소',
              style: TextStyle(fontSize: 16, color: ColorConfig.confirm),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => context.pop(true),
            child: Text(
              '삭제',
              style: TextStyle(fontSize: 16, color: ColorConfig.caution),
            ),
          ),
        ],
      ),
    );
  }
}