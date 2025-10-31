import "package:dio/dio.dart";
import "package:injectable/injectable.dart";
import "package:uy_dosh/base/api/client/api_client.dart";
import "package:uy_dosh/base/api/public_dio_configurator.dart";

abstract class IPublicApiClient extends IApiClient {
  IPublicApiClient(super.dio);
}

@LazySingleton(as: IPublicApiClient)
class PublicApiClient extends IPublicApiClient {
  PublicApiClient({required IPublicDioConfigurator configurator})
    : super(configurator.configure(Dio()));
}
