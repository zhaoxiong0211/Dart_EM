// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library EnergyVampires;

import 'dart:js';
import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:convert';
import 'dart:web_audio';

part 'sounds.dart';
part 'spinner.dart';
part 'touch.dart';
part 'tween.dart';
part 'utils.dart';


String STATIC_ROOT = "";

void main() {
  Sounds.loadSound("tick", "${STATIC_ROOT}sounds");
  Spinner spinner = new Spinner();
}

