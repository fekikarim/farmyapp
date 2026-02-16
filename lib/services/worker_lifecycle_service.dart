import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import '../models/worker_invitation_model.dart';
import '../models/worker_contract_model.dart';
import '../models/contract_negotiation_model.dart';

class WorkerLifecycleService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.1.21:3001',
  );

  // ─── Invitations (Phase 1) ───

  /// Farmer: invite worker to land
  static Future<WorkerInvitation?> inviteWorker({
    required String landId,
    required String workerId,
    String? message,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/workforce/lands/$landId/invite-worker'),
      body: jsonEncode({'worker_id': workerId, 'message': message}),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return WorkerInvitation.fromJson(body['data']);
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to invite worker');
  }

  /// Worker: respond to invitation (approve/decline)
  static Future<WorkerInvitation?> respondToInvitation({
    required String invitationId,
    required String response, // 'approve' or 'decline'
  }) async {
    final res = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/workforce/invitations/$invitationId/respond'),
      body: jsonEncode({'response': response}),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return WorkerInvitation.fromJson(body['data']);
    }
    final errorBody = jsonDecode(res.body);
    throw Exception(errorBody['message'] ?? 'Failed to respond to invitation');
  }

  /// Farmer: get invitations for a land (optionally filter by status)
  static Future<List<WorkerInvitation>> getLandInvitations(
    String landId, {
    String? status,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/v1/workforce/lands/$landId/invitations',
    ).replace(queryParameters: status != null ? {'status': status} : null);
    final response = await AuthService.authenticatedRequest('GET', uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => WorkerInvitation.fromJson(e)).toList();
    }
    return [];
  }

  /// Worker: get my invitations
  static Future<List<WorkerInvitation>> getMyInvitations() async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/me/invitations'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => WorkerInvitation.fromJson(e)).toList();
    }
    return [];
  }

  /// Investor: get approved workers for a land
  static Future<List<Map<String, dynamic>>> getApprovedWorkers(
    String landId,
  ) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/lands/$landId/approved-workers'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ─── Contracts (Phase 2) ───

  /// Investor: hire worker
  static Future<WorkerContract?> hireWorker({
    required String landId,
    required String invitationId,
    required double salaryAmount,
    required String salaryType,
    required String contractStartDate,
    required String contractEndDate,
    String? message,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/workforce/lands/$landId/hire-worker'),
      body: jsonEncode({
        'invitation_id': invitationId,
        'salary_amount': salaryAmount,
        'salary_type': salaryType,
        'contract_start_date': contractStartDate,
        'contract_end_date': contractEndDate,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return WorkerContract.fromJson(body['data']);
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to hire worker');
  }

  /// Worker: respond to contract (approve/decline)
  static Future<WorkerContract?> respondToContract({
    required String contractId,
    required String response,
  }) async {
    final res = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/workforce/contracts/$contractId/respond'),
      body: jsonEncode({'response': response}),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return WorkerContract.fromJson(body['data']);
    }
    final errorBody = jsonDecode(res.body);
    throw Exception(errorBody['message'] ?? 'Failed to respond to contract');
  }

  /// Investor: respond to worker counter-offer (accept/decline)
  static Future<WorkerContract?> investorRespondToContract({
    required String contractId,
    required String response,
  }) async {
    final res = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse(
        '$_baseUrl/api/v1/workforce/contracts/$contractId/investor-respond',
      ),
      body: jsonEncode({'response': response}),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return WorkerContract.fromJson(body['data']);
    }
    final errorBody = jsonDecode(res.body);
    throw Exception(errorBody['message'] ?? 'Failed to respond to contract');
  }

  /// Both: negotiate contract
  static Future<Map<String, dynamic>> negotiateContract({
    required String contractId,
    required String comment,
    double? proposedSalaryAmount,
    String? proposedSalaryType,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/workforce/contracts/$contractId/negotiate'),
      body: jsonEncode({
        'comment': comment,
        'proposed_salary_amount': proposedSalaryAmount,
        'proposed_salary_type': proposedSalaryType,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? {};
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to negotiate contract');
  }

  /// Both: get negotiation history
  static Future<List<ContractNegotiation>> getNegotiationHistory(
    String contractId,
  ) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse(
        '$_baseUrl/api/v1/workforce/contracts/$contractId/negotiations',
      ),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => ContractNegotiation.fromJson(e)).toList();
    }
    return [];
  }

  /// Both: edit the last negotiation message
  static Future<Map<String, dynamic>> editNegotiation({
    required String contractId,
    required String negotiationId,
    String? comment,
    double? proposedSalaryAmount,
    String? proposedSalaryType,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'PATCH',
      Uri.parse(
        '$_baseUrl/api/v1/workforce/contracts/$contractId/negotiations/$negotiationId',
      ),
      body: jsonEncode({
        'comment': comment,
        'proposed_salary_amount': proposedSalaryAmount,
        'proposed_salary_type': proposedSalaryType,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? {};
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to edit negotiation');
  }

  /// Both: delete (withdraw) the last negotiation message
  static Future<Map<String, dynamic>> deleteNegotiation({
    required String contractId,
    required String negotiationId,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'DELETE',
      Uri.parse(
        '$_baseUrl/api/v1/workforce/contracts/$contractId/negotiations/$negotiationId',
      ),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? {};
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to withdraw negotiation');
  }

  /// Investor: create payment for contract
  static Future<Map<String, dynamic>> createContractPayment(
    String contractId,
  ) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/workforce/contracts/$contractId/pay'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? {};
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(
      errorBody['message'] ?? 'Failed to create contract payment',
    );
  }

  /// Get contracts for a land
  static Future<List<WorkerContract>> getLandContracts(String landId) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/lands/$landId/contracts'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => WorkerContract.fromJson(e)).toList();
    }
    return [];
  }

  /// Investor: get negotiating contracts for a land
  static Future<List<WorkerContract>> getNegotiatingContracts(
    String landId,
  ) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse(
        '$_baseUrl/api/v1/workforce/lands/$landId/contracts/negotiating',
      ),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => WorkerContract.fromJson(e)).toList();
    }
    return [];
  }

  /// Get active contracts for a land
  static Future<List<WorkerContract>> getActiveContracts(String landId) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/lands/$landId/contracts/active'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => WorkerContract.fromJson(e)).toList();
    }
    return [];
  }

  /// Worker: get my contracts
  static Future<List<WorkerContract>> getMyContracts() async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/me/contracts'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => WorkerContract.fromJson(e)).toList();
    }
    return [];
  }

  /// Worker: get my balance
  static Future<Map<String, dynamic>> getMyBalance() async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/me/balance'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? {};
    }
    return {};
  }

  /// Get single contract
  static Future<WorkerContract?> getContract(String contractId) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/contracts/$contractId'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return WorkerContract.fromJson(body['data']);
    }
    return null;
  }

  /// Investor: suspend contract
  static Future<bool> suspendContract(String contractId) async {
    final response = await AuthService.authenticatedRequest(
      'PATCH',
      Uri.parse('$_baseUrl/api/v1/workforce/contracts/$contractId/suspend'),
    );
    return response.statusCode == 200;
  }

  /// Investor: terminate contract
  static Future<bool> terminateContract(String contractId) async {
    final response = await AuthService.authenticatedRequest(
      'PATCH',
      Uri.parse('$_baseUrl/api/v1/workforce/contracts/$contractId/terminate'),
    );
    return response.statusCode == 200;
  }
}
