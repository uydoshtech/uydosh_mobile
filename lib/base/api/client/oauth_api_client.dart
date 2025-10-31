import "package:dio/dio.dart";
import "package:injectable/injectable.dart";
import "package:uy_dosh/base/api/client/api_client.dart";
import "package:uy_dosh/base/api/oauth_dio_configurator.dart";

abstract class IOAuthApiClient extends IApiClient {
  IOAuthApiClient(super.dio);
}

@LazySingleton(as: IOAuthApiClient)
class OAuthApiClient extends IOAuthApiClient {
  OAuthApiClient({required IOAuthDioConfigurator configurator})
    : super(configurator.configure(Dio()));
}
