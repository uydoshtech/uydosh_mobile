import 'package:uy_dosh/base/api/client/json_encodable.dart';
import 'package:uy_dosh/base/api/client/oauth_api_client.dart';
import 'package:uy_dosh/base/util/environment_util.dart';
import 'package:uy_dosh/domain/models/hostel.dart';

abstract class IHostelService { Future<List<Hostel>> list({int? districtId, String? gender}); Future<Hostel> detail(int id); Future<void> requestPlace(int hostelId, {int? unitId, String? message}); }
class HostelService implements IHostelService {
  HostelService(this._api); final IOAuthApiClient _api;
  @override Future<List<Hostel>> list({int? districtId, String? gender}) async { final json=await _api.get<List<dynamic>>('/hostels',(v)=>v as List<dynamic>,basePath:EnvironmentUtil.basePath,queryParameters:{if(districtId!=null)'district_id':districtId,if(gender!=null)'gender':gender}); return json.map((v)=>Hostel.fromJson(Map<String,dynamic>.from(v as Map))).toList(); }
  @override Future<Hostel> detail(int id) async => Hostel.fromJson(await _api.get<Map<String,dynamic>>('/hostels/$id',(v)=>Map<String,dynamic>.from(v as Map),basePath:EnvironmentUtil.basePath));
  @override Future<void> requestPlace(int hostelId,{int? unitId,String? message}) async { await _api.post<dynamic,_HostelRequest>('/hostels/$hostelId/requests',(v)=>v,basePath:EnvironmentUtil.basePath,data:_HostelRequest(unitId,message)); }
}
class _HostelRequest implements IJsonEncodable { const _HostelRequest(this.unitId,this.message); final int? unitId; final String? message; @override Map<String,dynamic> toJson()=>{if(unitId!=null)'hostel_unit_id':unitId,if(message?.isNotEmpty??false)'message':message}; }
