import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class TournamentInfoDTO {
  final String id;
  final String tournamentName;
  final DateTime startDateTime;
  final int maxPlayers;
  final String format;
  final String extraInfo;
  final double price;
  final String organizerNickname;
  final String companionCode;
  final bool openTournament;
  final bool fullTournament;
  final bool finished;

  TournamentInfoDTO({
    required this.id,
    required this.tournamentName,
    required this.startDateTime,
    required this.maxPlayers,
    required this.format,
    required this.extraInfo,
    required this.price,
    required this.organizerNickname,
    required this.companionCode,
    required this.openTournament,
    required this.fullTournament,
    required this.finished,
  });

  factory TournamentInfoDTO.fromJson(Map<String, dynamic> json) {
    return TournamentInfoDTO(
      id: json['id']?.toString() ?? '',
      tournamentName: json['tournamentName'] ?? '',
      startDateTime: DateTime.parse(json['startDateTime'].toString()),
      maxPlayers: (json['maxPlayers'] is int) ? json['maxPlayers'] : int.tryParse(json['maxPlayers']?.toString() ?? '') ?? 0,
      format: json['format'] ?? '',
      extraInfo: json['extraInfo'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      organizerNickname: json['organizerNickname'] ?? '',
      companionCode: json['companionCode'] ?? '',
      openTournament: json['openTournament'] == true,
      fullTournament: json['fullTournament'] == true,
      finished: json['finished'] == true,
    );
  }
}

class TournamentsResponse {
  final String message;
  final List<TournamentInfoDTO> tournaments;

  TournamentsResponse({required this.message, required this.tournaments});

  factory TournamentsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['tournaments'] ?? [];
    return TournamentsResponse(
      message: json['message'] ?? '',
      tournaments: list.map((e) => TournamentInfoDTO.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});
  static const String routeName = '/pyramid/store/home';

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  bool _loading = true;
  String? _error;
  List<TournamentInfoDTO> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Construir URL a partir del baseUrl en AuthService
      final root = AuthService.baseUrl.replaceFirst('/auth', '');
      final url = Uri.parse('$root/store/tournaments/home');

      final headers = await AuthService().getAuthHeaders();
      final resp = await http.get(url, headers: headers);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = TournamentsResponse.fromJson(body);
        if (!mounted) return;
        setState(() {
          _tournaments = data.tournaments;
        });
      } else {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildCard(TournamentInfoDTO t) {
    final start = t.startDateTime.toLocal();
    final dateStr = '${start.year}-${start.month.toString().padLeft(2,'0')}-${start.day.toString().padLeft(2,'0')} ${start.hour.toString().padLeft(2,'0')}:${start.minute.toString().padLeft(2,'0')}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(t.tournamentName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('Fecha: $dateStr'),
            Text('Formato: ${t.format} • Max players: ${t.maxPlayers}'),
            if (t.extraInfo.isNotEmpty) Text('Info: ${t.extraInfo}'),
            Text('Precio: ${t.price.toString()}'),
            Text('Organizador: ${t.organizerNickname}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (t.openTournament) const Chip(label: Text('Open')),
            if (t.fullTournament) const Chip(label: Text('Full')),
            if (t.finished) const Chip(label: Text('Finished')),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          // Navegar a detalles si existe ruta/detalle
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store — Upcoming Tournaments'),
        backgroundColor: AppColors.darkBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadTournaments,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : (_error != null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error: $_error', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _loadTournaments, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTournaments,
                  child: _tournaments.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('No upcoming tournaments')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _tournaments.length,
                          itemBuilder: (_, i) => _buildCard(_tournaments[i]),
                        ),
                ),
    );
  }
}