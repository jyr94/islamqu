import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:islamqu/page/qiblah.dart';
import 'package:islamqu/helper/constant.dart';
class SquareButton extends StatelessWidget {
  final String label;
  final Icon icon;
  final VoidCallback onPressed;
  SquareButton({required this.label, required this.icon,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 60.0,
          height: 60.0,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(20.0),
            onPressed: () {
              onPressed();
            },
            color: buttonCollors,
            child: Icon(icon.icon, size: 26.0,color: mainColor,),
          ),

        ),
        SizedBox(
          height: 8.0,
        ),
        Container(
          width: 60.0,
          height: 20.0,
          child: Center(
            child: Text(
              label
              // style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}