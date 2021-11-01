
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Mybutton extends CupertinoButton{
Mybutton(text,fn): super  (child: Text(text, style:TextStyle(fontSize:15, color: Colors.black)),
  borderRadius: BorderRadius.circular(50), onPressed:fn);
}
 