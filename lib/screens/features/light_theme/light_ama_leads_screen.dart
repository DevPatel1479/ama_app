import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/models/ama_lead_model.dart';
import 'package:ama_legal_solutions/models/bill_cut_leads_model.dart';
import 'package:ama_legal_solutions/provider/ama/ama_leads_provider.dart';
import 'package:ama_legal_solutions/provider/billcut/billcut_leads_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

String _formatSyncedAt(DateTime? date) {
  if (date == null) return "Not synced yet";

  return DateFormat('dd MMM yyyy • hh:mm a').format(date);
}

class LightLeadCard extends StatelessWidget {
  final AmaLeadModel lead;

  const LightLeadCard({super.key, required this.lead});

  Future<void> _openDialer(String phone) async {
    final Uri uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;

    return GestureDetector(
      onTap: () => _openDialer(lead.mobile.toString()),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Name + Synced At (right aligned)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name (left)
                Expanded(
                  child: Text(
                    lead.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isSmall ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// Synced At (right)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatSyncedAt(lead.syncedAt),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: isSmall ? 10 : 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              "Source: ${lead.sourceDatabase}",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: isSmall ? 12 : 13,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.call, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  lead.mobile.toString(),
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: isSmall ? 13 : 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LightBillcutLeadCard extends StatelessWidget {
  final BillcutLead lead;
  const LightBillcutLeadCard({Key? key, required this.lead}) : super(key: key);

  Future<void> _openDialer(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;

    return GestureDetector(
      onTap: () => _openDialer(lead.mobile),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + synced
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    lead.name ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isSmall ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatSyncedAt(lead.syncedDate),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: isSmall ? 10 : 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.call, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  lead.mobile ?? '—',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: isSmall ? 13 : 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LightLeadsTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const LightLeadsTabBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _tabItem("AMA Leads", 0, isSmall),
          _tabItem("BillCut Leads", 1, isSmall),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index, bool isSmall) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontSize: isSmall ? 12 : 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LightAmaLeadsScreen extends StatefulWidget {
  final String name;

  const LightAmaLeadsScreen({super.key, required this.name});

  @override
  State<LightAmaLeadsScreen> createState() => _LightAmaLeadsScreenState();
}

class _LightAmaLeadsScreenState extends State<LightAmaLeadsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _currentTab = 0;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AmaLeadsProvider>().fetchLeads(name: widget.name);
      context.read<BillCutLeadsProvider>().fetchLeads(name: widget.name);
    });

    _scrollController.addListener(() {
      final pixels = _scrollController.position.pixels;
      final max = _scrollController.position.maxScrollExtent;
      if (pixels >= max - 200) {
        if (_currentTab == 0) {
          final p = context.read<AmaLeadsProvider>();
          if (p.hasMore && !p.isFetchingMore) p.fetchMore();
        } else {
          final p = context.read<BillCutLeadsProvider>();
          if (p.hasMore && !p.isFetchingMore) p.fetchMore();
        }
      }
    });
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    if (_currentTab == 0) {
      await context.read<AmaLeadsProvider>().fetchLeads(name: widget.name);
    } else {
      await context.read<BillCutLeadsProvider>().fetchLeads(name: widget.name);
    }
  }

  Widget _buildSearchLight({
    required String search,
    required Function(String) onChanged,
    required VoidCallback onClear,
  }) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, isSmall ? 6 : 10, 16, isSmall ? 6 : 10),
      child: TextField(
        controller: _searchController,
        onChanged: onChanged,
        style: TextStyle(color: Colors.black87, fontSize: isSmall ? 13 : 15),
        cursorColor: Colors.black54,
        decoration: InputDecoration(
          hintText: "Search by name or phone",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          suffixIcon: search.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    onClear();
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = w * 0.22;

    print("created ama leads screen .. ");

    return Scaffold(
      resizeToAvoidBottomInset: false,

      backgroundColor: Color(0xFFF8BD00),

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(topPadding + appBarHeight),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding,
            left: w * 0.04,
            right: w * 0.04,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 244, 206, 83),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(w * 0.07),
              bottomRight: Radius.circular(w * 0.07),
            ),
          ),
          child: SizedBox(
            height: appBarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Image.asset(
                    AppAssets.backArrowIcon,
                    width: w * 0.06,
                    height: w * 0.06,
                    fit: BoxFit.contain,
                    color: Colors.black,
                  ),
                  onPressed: () => context.pop(),
                  splashRadius: 24,
                ),

                SizedBox(width: w * 0.02),

                Expanded(
                  child: Text(
                    "Leads",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: w * 0.065,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// ✅ BODY WRAPPED IN GradientTopLayout
      body: Container(
        color: Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: GradientTopLayout(
            screenName: "home",
            keepExpanded: false,
            child: Consumer2<AmaLeadsProvider, BillCutLeadsProvider>(
              builder: (context, amaProvider, billCutProvider, _) {
                final isAma = _currentTab == 0;
                return Column(
                  children: [
                    /// 🔍 SEARCH BAR (always visible)
                    LightLeadsTabBar(
                      currentIndex: _currentTab,
                      onChanged: (i) {
                        setState(() {
                          _currentTab = i;
                          _searchController.clear();
                        });

                        if (i == 0) {
                          final p = context.read<AmaLeadsProvider>();
                          p.setSearch("");
                          // fetch if empty or never loaded
                          if (p.leads.isEmpty && !p.isLoading) {
                            p.fetchLeads(name: widget.name, reset: true);
                          }
                        } else {
                          final p = context.read<BillCutLeadsProvider>();
                          p.setSearch("");
                          // important: always try to fetch immediately when switching to BillCut
                          // (avoid waiting for debounce). Use reset: false if you want append behavior.
                          if (!p.isLoading) {
                            // If you want to avoid refetch every time and only fetch when empty:
                            // if (p.leads.isEmpty || !p.hasLoadedOnce) p.fetchLeads(name: widget.name, reset: true);
                            p.fetchLeads(name: widget.name, reset: true);
                          }
                        }
                      },
                    ),
                    _buildSearchLight(
                      search: isAma
                          ? amaProvider.search
                          : billCutProvider.search,
                      onChanged: (v) {
                        if (_currentTab == 0) {
                          amaProvider.setSearch(v);
                        } else {
                          billCutProvider.setSearch(v);
                        }
                      },
                      onClear: () {
                        if (_currentTab == 0) {
                          amaProvider.setSearch("");
                        } else {
                          billCutProvider.setSearch("");
                        }
                      },
                    ),

                    /// 📦 CONTENT
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: Colors.white,
                        backgroundColor: const Color(0xFF1F1F1F),
                        child: isAma
                            ? (amaProvider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : amaProvider.leads.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "No AMA leads found",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).padding.bottom +
                                            16,
                                      ),
                                      itemCount:
                                          amaProvider.leads.length +
                                          (amaProvider.isFetchingMore ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index == amaProvider.leads.length) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 20,
                                            ),
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        final lead = amaProvider.leads[index];
                                        return LightLeadCard(lead: lead);
                                      },
                                    ))
                            : (billCutProvider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : billCutProvider.leads.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "No BillCut leads found",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).padding.bottom +
                                            16,
                                      ),
                                      itemCount:
                                          billCutProvider.leads.length +
                                          (billCutProvider.isFetchingMore
                                              ? 1
                                              : 0),
                                      itemBuilder: (context, index) {
                                        if (index ==
                                            billCutProvider.leads.length) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 20,
                                            ),
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        final item =
                                            billCutProvider.leads[index];
                                        // it's a BillcutLead already; safe to render
                                        return LightBillcutLeadCard(lead: item);
                                      },
                                    )),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
