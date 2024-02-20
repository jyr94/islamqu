import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:islamqu/page/qiblah.dart';
import 'package:islamqu/helper/constant.dart';
class SquareButton extends StatelessWidget {
  final String label;
  final Icon icon;
  final VoidCallback onPressed;
  final MaterialColor btnClr;
  SquareButton({required this.label, required this.icon,required this.onPressed,required this.btnClr});

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
            child: Icon(icon.icon, size: 30.0,color: btnClr,weight: 1000,),
          ),

        ),
        // SizedBox(
        //   height: 8.0,
        // ),
        Container(
          width: 60.0,
          height: 20.0,
          child: Center(
            child: Text(
              label,
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold,fontSize: 20)
            ),
          ),
        ),
      ],
    );
  }
}