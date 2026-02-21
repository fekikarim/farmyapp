import 'package:flutter/material.dart';
import '../models/worker_invitation_model.dart';
import '../models/worker_contract_model.dart';
import '../models/contract_negotiation_model.dart';
import '../models/worker_profile_model.dart';
import '../models/proof_request_model.dart';
import '../services/worker_lifecycle_service.dart';
import '../services/proof_service.dart';
import '../services/socket_service.dart';

class WorkerLifecycleProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();
  bool _socketInitialized = false;
  // ─── Invitations State ───
  List<WorkerInvitation> _landInvitations = [];
  bool _landInvitationsLoading = false;

  List<WorkerInvitation> _myInvitations = [];
  bool _myInvitationsLoading = false;

  // Approved workers for investor
  List<WorkerProfile> _approvedWorkers = [];
  Map<String, String> _workerInvitationMap = {}; // workerId → invitationId
  bool _approvedWorkersLoading = false;
  String? _approvedWorkersError;

  // ─── Contracts State ───
  List<WorkerContract> _landContracts = [];
  bool _landContractsLoading = false;

  List<WorkerContract> _negotiatingContracts = [];
  bool _negotiatingContractsLoading = false;
  String? _negotiatingContractsError;

  List<WorkerContract> _activeContracts = [];
  bool _activeContractsLoading = false;
  String? _activeContractsError;

  List<WorkerContract> _myContracts = [];
  bool _myContractsLoading = false;
  String? _myContractsError;

  // ─── Negotiation State ───
  List<ContractNegotiation> _negotiations = [];
  bool _negotiationsLoading = false;

  // ─── Balance State ───
  Map<String, dynamic> _myBalance = {};
  bool _balanceLoading = false;

  // ─── Proofs State ───
  List<ProofRequest> _landProofs = [];
  bool _landProofsLoading = false;

  List<ProofRequest> _myProofs = [];
  bool _myProofsLoading = false;

  String? _currentLandId;

  // ─── Getters ───
  List<WorkerInvitation> get landInvitations => _landInvitations;
  bool get landInvitationsLoading => _landInvitationsLoading;

  // Convenience aliases
  List<WorkerInvitation> get invitations => _landInvitations;
  List<WorkerInvitation> get pendingInvitations =>
      _landInvitations.where((i) => i.isPending).toList();
  List<WorkerContract> get contracts => _negotiatingContracts;
  bool get isLoading =>
      _approvedWorkersLoading ||
      _negotiatingContractsLoading ||
      _activeContractsLoading;

  List<WorkerInvitation> get myInvitations => _myInvitations;
  bool get myInvitationsLoading => _myInvitationsLoading;

  List<WorkerProfile> get approvedWorkers => _approvedWorkers;
  bool get approvedWorkersLoading => _approvedWorkersLoading;
  String? get approvedWorkersError => _approvedWorkersError;

  String? getInvitationIdForWorker(String workerId) =>
      _workerInvitationMap[workerId];

  List<WorkerContract> get landContracts => _landContracts;
  bool get landContractsLoading => _landContractsLoading;

  List<WorkerContract> get negotiatingContracts => _negotiatingContracts;
  bool get negotiatingContractsLoading => _negotiatingContractsLoading;
  String? get negotiatingContractsError => _negotiatingContractsError;

  List<WorkerContract> get activeContracts => _activeContracts;
  bool get activeContractsLoading => _activeContractsLoading;
  String? get activeContractsError => _activeContractsError;

  List<WorkerContract> get myContracts => _myContracts;
  bool get myContractsLoading => _myContractsLoading;
  String? get myContractsError => _myContractsError;

  List<ContractNegotiation> get negotiations => _negotiations;
  bool get negotiationsLoading => _negotiationsLoading;

  Map<String, dynamic> get myBalance => _myBalance;
  bool get balanceLoading => _balanceLoading;

  String? get currentLandId => _currentLandId;

  List<ProofRequest> get landProofs => _landProofs;
  List<ProofRequest> get pendingLandProofs =>
      _landProofs.where((p) => p.isPending).toList();
  bool get landProofsLoading => _landProofsLoading;

  List<ProofRequest> get myProofs => _myProofs;
  List<ProofRequest> get pendingMyProofs =>
      _myProofs.where((p) => p.isPending).toList();
  List<ProofRequest> get historyMyProofs =>
      _myProofs.where((p) => !p.isPending).toList();
  bool get myProofsLoading => _myProofsLoading;

  // ─── Invitation Actions ───

  String? _lastError;
  String? get lastError => _lastError;

  Future<bool> inviteWorker({
    required String landId,
    required String workerId,
    String? message,
  }) async {
    _lastError = null;
    try {
      final invitation = await WorkerLifecycleService.inviteWorker(
        landId: landId,
        workerId: workerId,
        message: message,
      );
      // Instantly add the new invitation to the local list so UI updates
      if (invitation != null) {
        _landInvitations = [..._landInvitations, invitation];
        notifyListeners();
      }
      return true;
    } catch (e) {
      _lastError = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  Future<bool> respondToInvitation({
    required String invitationId,
    required String response,
  }) async {
    try {
      await WorkerLifecycleService.respondToInvitation(
        invitationId: invitationId,
        response: response,
      );
      // Refresh invitations
      await loadMyInvitations();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadLandInvitations(String landId, {String? status}) async {
    _landInvitationsLoading = true;
    notifyListeners();
    try {
      _landInvitations = await WorkerLifecycleService.getLandInvitations(
        landId,
        status: status,
      );
    } catch (e) {
      _landInvitations = [];
    } finally {
      _landInvitationsLoading = false;
      notifyListeners();
    }
  }

  /// Alias for loadLandInvitations
  Future<void> loadInvitationsByLand(String landId, {String? status}) =>
      loadLandInvitations(landId, status: status);

  Future<void> loadMyInvitations() async {
    _myInvitationsLoading = true;
    notifyListeners();
    try {
      _myInvitations = await WorkerLifecycleService.getMyInvitations();
    } catch (e) {
      _myInvitations = [];
    } finally {
      _myInvitationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadApprovedWorkers(String landId) async {
    _currentLandId = landId;
    _approvedWorkersLoading = true;
    _approvedWorkersError = null;
    notifyListeners();
    try {
      final rawList = await WorkerLifecycleService.getApprovedWorkers(landId);
      _approvedWorkers = [];
      _workerInvitationMap = {};
      for (final entry in rawList) {
        final profile = entry['profile'];
        final invitation = entry['invitation'];
        if (profile != null) {
          _approvedWorkers.add(WorkerProfile.fromJson(profile));
        }
        if (invitation != null && profile != null) {
          final workerId = profile['user_id'] ?? invitation['worker_id'];
          if (workerId != null && invitation['id'] != null) {
            _workerInvitationMap[workerId] = invitation['id'];
          }
        }
      }
    } catch (e) {
      _approvedWorkers = [];
      _workerInvitationMap = {};
      _approvedWorkersError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _approvedWorkersLoading = false;
      notifyListeners();
    }
  }

  // ─── Contract Actions ───

  Future<String?> hireWorker({
    required String landId,
    required String workerId,
    required double salaryAmount,
    required String salaryType,
    required String contractStartDate,
    required String contractEndDate,
    String? message,
  }) async {
    try {
      // Look up the invitation ID from the approved workers map
      final invitationId = _workerInvitationMap[workerId];
      if (invitationId == null) {
        return 'No approved invitation found for this worker';
      }
      await WorkerLifecycleService.hireWorker(
        landId: landId,
        invitationId: invitationId,
        salaryAmount: salaryAmount,
        salaryType: salaryType,
        contractStartDate: contractStartDate,
        contractEndDate: contractEndDate,
        message: message,
      );
      return null; // Success
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<bool> respondToContract({
    required String contractId,
    required String response,
  }) async {
    try {
      await WorkerLifecycleService.respondToContract(
        contractId: contractId,
        response: response,
      );
      await loadMyContracts();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> negotiateContract({
    required String contractId,
    required String comment,
    double? proposedSalaryAmount,
    String? proposedSalaryType,
  }) async {
    _lastError = null;
    try {
      final result = await WorkerLifecycleService.negotiateContract(
        contractId: contractId,
        comment: comment,
        proposedSalaryAmount: proposedSalaryAmount,
        proposedSalaryType: proposedSalaryType,
      );
      // Update local contract state if returned
      if (result['contract'] != null) {
        final updated = WorkerContract.fromJson(result['contract']);
        _updateContractInLists(updated);
      }
      await loadNegotiationHistory(contractId);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  Future<bool> investorRespondToContract({
    required String contractId,
    required String response,
  }) async {
    _lastError = null;
    try {
      final contract = await WorkerLifecycleService.investorRespondToContract(
        contractId: contractId,
        response: response,
      );
      if (contract != null) {
        _updateContractInLists(contract);
      }
      return true;
    } catch (e) {
      _lastError = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  Future<void> loadNegotiationHistory(String contractId) async {
    _negotiationsLoading = true;
    notifyListeners();
    try {
      _negotiations = await WorkerLifecycleService.getNegotiationHistory(
        contractId,
      );
    } catch (e) {
      _negotiations = [];
    } finally {
      _negotiationsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editNegotiation({
    required String contractId,
    required String negotiationId,
    String? comment,
    double? proposedSalaryAmount,
    String? proposedSalaryType,
  }) async {
    _lastError = null;
    try {
      final result = await WorkerLifecycleService.editNegotiation(
        contractId: contractId,
        negotiationId: negotiationId,
        comment: comment,
        proposedSalaryAmount: proposedSalaryAmount,
        proposedSalaryType: proposedSalaryType,
      );
      // Update local contract state if returned
      if (result['contract'] != null) {
        final updated = WorkerContract.fromJson(result['contract']);
        _updateContractInLists(updated);
      }
      // Update the negotiation in local list
      if (result['negotiation'] != null) {
        final updatedNeg = ContractNegotiation.fromJson(result['negotiation']);
        final idx = _negotiations.indexWhere((n) => n.id == updatedNeg.id);
        if (idx >= 0) {
          _negotiations[idx] = updatedNeg;
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _lastError = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  Future<bool> deleteNegotiation({
    required String contractId,
    required String negotiationId,
  }) async {
    _lastError = null;
    try {
      final result = await WorkerLifecycleService.deleteNegotiation(
        contractId: contractId,
        negotiationId: negotiationId,
      );
      // Update local contract state if returned
      if (result['contract'] != null) {
        final updated = WorkerContract.fromJson(result['contract']);
        _updateContractInLists(updated);
      }
      // Remove the deleted negotiation from local list
      _negotiations.removeWhere((n) => n.id == negotiationId);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  Future<Map<String, dynamic>> createContractPayment(String contractId) async {
    try {
      return await WorkerLifecycleService.createContractPayment(contractId);
    } catch (e) {
      return {};
    }
  }

  Future<void> loadLandContracts(String landId) async {
    _currentLandId = landId;
    _landContractsLoading = true;
    notifyListeners();
    try {
      _landContracts = await WorkerLifecycleService.getLandContracts(landId);
    } catch (e) {
      _landContracts = [];
    } finally {
      _landContractsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNegotiatingContracts(String landId) async {
    _currentLandId = landId;
    _negotiatingContractsLoading = true;
    _negotiatingContractsError = null;
    notifyListeners();
    try {
      _negotiatingContracts =
          await WorkerLifecycleService.getNegotiatingContracts(landId);
    } catch (e) {
      _negotiatingContracts = [];
      _negotiatingContractsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _negotiatingContractsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActiveContracts(String landId) async {
    _currentLandId = landId;
    _activeContractsLoading = true;
    _activeContractsError = null;
    notifyListeners();
    try {
      _activeContracts = await WorkerLifecycleService.getActiveContracts(
        landId,
      );
    } catch (e) {
      _activeContracts = [];
      _activeContractsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _activeContractsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyContracts() async {
    _myContractsLoading = true;
    _myContractsError = null;
    notifyListeners();
    try {
      _myContracts = await WorkerLifecycleService.getMyContracts();
    } catch (e) {
      _myContracts = [];
      _myContractsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _myContractsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyBalance() async {
    _balanceLoading = true;
    notifyListeners();
    try {
      _myBalance = await WorkerLifecycleService.getMyBalance();
    } catch (e) {
      _myBalance = {};
    } finally {
      _balanceLoading = false;
      notifyListeners();
    }
  }

  // ─── Proof Actions ───

  Future<void> loadLandProofs(String landId) async {
    _currentLandId = landId;
    _landProofsLoading = true;
    notifyListeners();
    try {
      final List<dynamic> raw = await ProofService.getMyProofs();
      // Filter by landId locally since API returns all my proofs
      _landProofs = raw
          .map((json) => ProofRequest.fromJson(json))
          .where((p) => (p.landId?.toLowerCase() == landId.toLowerCase()))
          .toList();
    } catch (e) {
      _landProofs = [];
    } finally {
      _landProofsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyProofs() async {
    _myProofsLoading = true;
    notifyListeners();
    try {
      final List<dynamic> raw = await ProofService.getMyProofs();
      _myProofs = raw.map((json) => ProofRequest.fromJson(json)).toList();
    } catch (e) {
      _myProofs = [];
    } finally {
      _myProofsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> suspendContract(String contractId) async {
    try {
      return await WorkerLifecycleService.suspendContract(contractId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> terminateContract(String contractId) async {
    try {
      final success = await WorkerLifecycleService.terminateContract(
        contractId,
      );
      if (success) {
        // Remove from active contracts list immediately
        _activeContracts.removeWhere((c) => c.id == contractId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _lastError = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  // ─── Socket Connection ───

  /// Call this when the user is authenticated to connect and listen for events.
  Future<void> initSocket() async {
    if (_socketInitialized) return;
    _socketInitialized = true;

    await _socketService.connect();

    _socketService.on('invitation_created', (data) {
      if (data is Map<String, dynamic>) handleInvitationCreated(data);
    });
    _socketService.on('invitation_responded', (data) {
      if (data is Map<String, dynamic>) handleInvitationResponded(data);
    });
    _socketService.on('contract_created', (data) {
      if (data is Map<String, dynamic>) handleContractCreated(data);
    });
    _socketService.on('contract_payment_required', (data) {
      if (data is Map<String, dynamic>) handleContractPaymentRequired(data);
    });
    _socketService.on('contract_negotiated', (data) {
      if (data is Map<String, dynamic>) handleContractNegotiated(data);
    });
    _socketService.on('contract_activated', (data) {
      if (data is Map<String, dynamic>) handleContractActivated(data);
    });
    _socketService.on('contract_suspended', (data) {
      if (data is Map<String, dynamic>) handleContractSuspended(data);
    });
    _socketService.on('contract_terminated', (data) {
      if (data is Map<String, dynamic>) handleContractTerminated(data);
    });
    _socketService.on('contract_accepted', (data) {
      if (data is Map<String, dynamic>) handleContractAccepted(data);
    });
    _socketService.on('contract_declined', (data) {
      if (data is Map<String, dynamic>) handleContractDeclined(data);
    });
    _socketService.on('negotiation_edited', (data) {
      if (data is Map<String, dynamic>) handleNegotiationEdited(data);
    });
    _socketService.on('negotiation_deleted', (data) {
      if (data is Map<String, dynamic>) handleNegotiationDeleted(data);
    });
    _socketService.on('proof_requested', (data) {
      if (data is Map<String, dynamic>) handleProofRequested(data);
    });
    _socketService.on('proof_status_updated', (data) {
      if (data is Map<String, dynamic>) handleProofStatusUpdated(data);
    });
  }

  /// Call this on logout to clean up the socket connection.
  void disposeSocket() {
    _socketService.disconnect();
    _socketInitialized = false;
  }

  // ─── Real-time Socket Updates ───

  void handleInvitationCreated(Map<String, dynamic> data) {
    if (data['invitation'] != null) {
      final inv = WorkerInvitation.fromJson(data['invitation']);
      _myInvitations.insert(0, inv);
      notifyListeners();
    }
  }

  void handleInvitationResponded(Map<String, dynamic> data) {
    if (data['invitation'] != null) {
      final inv = WorkerInvitation.fromJson(data['invitation']);
      // Remove from land invitations if no longer pending (approved/declined)
      if (!inv.isPending) {
        _landInvitations.removeWhere((i) => i.id == inv.id);
      } else {
        final idx = _landInvitations.indexWhere((i) => i.id == inv.id);
        if (idx >= 0) {
          _landInvitations[idx] = inv;
        }
      }
      notifyListeners();
    }
  }

  void handleContractCreated(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _myContracts.insert(0, contract);
      notifyListeners();
    }
  }

  void handleContractPaymentRequired(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _updateContractInLists(contract);
    }
  }

  void handleContractNegotiated(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _updateContractInLists(contract);
    }
    if (data['negotiation'] != null) {
      final neg = ContractNegotiation.fromJson(data['negotiation']);
      _negotiations.add(neg);
      notifyListeners();
    }
  }

  void handleContractActivated(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _updateContractInLists(contract);
    }
  }

  void handleContractSuspended(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _updateContractInLists(contract);
    }
  }

  void handleContractTerminated(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _updateContractInLists(contract);
    }
  }

  void handleContractAccepted(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _updateContractInLists(contract);
    }
  }

  void handleContractDeclined(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _updateContractInLists(contract);
    }
  }

  void handleNegotiationEdited(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _updateContractInLists(contract);
    }
    if (data['negotiation'] != null) {
      final neg = ContractNegotiation.fromJson(data['negotiation']);
      final idx = _negotiations.indexWhere((n) => n.id == neg.id);
      if (idx >= 0) {
        _negotiations[idx] = neg;
      }
      notifyListeners();
    }
  }

  void handleNegotiationDeleted(Map<String, dynamic> data) {
    if (data['contract'] != null) {
      final contract = WorkerContract.fromJson(data['contract']);
      _updateContractInLists(contract);
    }
    if (data['deletedNegotiationId'] != null) {
      _negotiations.removeWhere((n) => n.id == data['deletedNegotiationId']);
      notifyListeners();
    }
  }

  void handleProofRequested(Map<String, dynamic> data) {
    if (data['proof'] != null) {
      final proof = ProofRequest.fromJson(data['proof']);
      
      // Update land-specific list if it matches the current land
      if (_currentLandId != null && 
          proof.landId?.toLowerCase() == _currentLandId!.toLowerCase()) {
        if (!_landProofs.any((p) => p.id == proof.id)) {
          _landProofs.insert(0, proof);
        }
      }

      // Update global list for worker
      if (!_myProofs.any((p) => p.id == proof.id)) {
        _myProofs.insert(0, proof);
      }
      notifyListeners();
    }
  }

  void handleProofStatusUpdated(Map<String, dynamic> data) {
    if (data['proof'] != null) {
      final proof = ProofRequest.fromJson(data['proof']);
      
      // Update in my list
      final idx = _myProofs.indexWhere((p) => p.id == proof.id);
      if (idx >= 0) {
        _myProofs[idx] = proof;
      } else {
        _myProofs.insert(0, proof);
      }

      // Update in land list (only if it belongs to the current land)
      if (_currentLandId != null && 
          proof.landId?.toLowerCase() == _currentLandId!.toLowerCase()) {
        final idxInLand = _landProofs.indexWhere((p) => p.id == proof.id);
        if (idxInLand >= 0) {
          _landProofs[idxInLand] = proof;
        } else {
          _landProofs.insert(0, proof);
        }
      }
      notifyListeners();
    }
  }

  void _updateContractInLists(WorkerContract contract) {
    // Update in myContracts
    final idx1 = _myContracts.indexWhere((c) => c.id == contract.id);
    if (idx1 >= 0) _myContracts[idx1] = contract;

    // Update in negotiatingContracts
    final idx2 = _negotiatingContracts.indexWhere((c) => c.id == contract.id);
    if (idx2 >= 0) {
      if (contract.isActive || contract.isSuspended) {
        _negotiatingContracts.removeAt(idx2);
        _activeContracts.insert(0, contract);
      } else if (contract.isTerminated ||
          contract.isHiringDeclined ||
          contract.isExpired) {
        _negotiatingContracts.removeAt(idx2);
      } else {
        _negotiatingContracts[idx2] = contract;
      }
    }

    // Update in activeContracts
    final idx3 = _activeContracts.indexWhere((c) => c.id == contract.id);
    if (idx3 >= 0) {
      if (contract.isTerminated) {
        _activeContracts.removeAt(idx3);
      } else {
        _activeContracts[idx3] = contract;
      }
    }

    notifyListeners();
  }
}
