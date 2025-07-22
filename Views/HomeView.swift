import SwiftUI

struct HomeView: View {
    @ObservedObject var dataManager: AuditDataManager
    @ObservedObject var router: AppRouter
    @State private var showingDraftsSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Welcome Header
            VStack(spacing: 8) {
                Text("Welcome to LagAudit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Professional dairy farm auditing")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Main Actions Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                // New Audit Card
                Button {
                    router.navigateToNewAudit()
                } label: {
                    VStack(spacing: 16) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("New Audit")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Start a fresh audit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Drafts Card
                Button {
                    showingDraftsSheet = true
                } label: {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Drafts")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Resume saved drafts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // History Card
                Button {
                    router.navigateToHistory()
                } label: {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        
                        Text("History")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("View past audits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Settings Card
                Button {
                    router.navigateToSettings()
                } label: {
                    VStack(spacing: 16) {
                        Image(systemName: "gear")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Configure app")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingDraftsSheet) {
            DraftListView(dataManager: dataManager, router: router)
        }
    }
} 