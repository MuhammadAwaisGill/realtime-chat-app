
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ZegoConfig {

  static final int appID = int.parse(dotenv.env['ZEGO_APP_ID']!);
  static final String appSign = dotenv.env['ZEGO_APP_SIGN']!;

}

