import SwiftUI

/// One section of a long-form info page — a heading and its paragraphs. Mirrors
/// the `LegalSection` shape on the e-z.rsvp website.
struct LegalSection: Identifiable {
    let title: String
    let body: [String]
    var id: String { title }
}

/// Renders a long-form policy / support page (Terms, Privacy, Safety, Support)
/// in the app's light glass style. The copy is lifted verbatim from the
/// e-z.rsvp website's `LegalPage` component — edit the two together so they
/// stay in sync.
struct LegalPage: View {
    let kicker: String
    let title: String
    let subtitle: String
    let updated: String
    let sections: [LegalSection]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Space.xl) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(kicker.uppercased())
                        .font(.caption2.weight(.bold)).tracking(2)
                        .foregroundStyle(Theme.violet)
                    Text(title)
                        .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                    Text(subtitle)
                        .font(.subheadline).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Label("Last updated: \(updated)", systemImage: "clock.arrow.circlepath")
                        .font(.caption).foregroundStyle(.secondary)
                        .padding(.top, 2)
                }

                VStack(alignment: .leading, spacing: Theme.Space.lg) {
                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title).font(.title3.weight(.bold))
                            ForEach(section.body, id: \.self) { paragraph in
                                Text(paragraph)
                                    .font(.subheadline).foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Theme.Space.lg)
                        .glass(cornerRadius: Theme.Radius.md)
                    }
                }
            }
            .padding(Theme.Space.lg)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Content (mirrored from the e-z.rsvp website)

extension LegalPage {
    static var termsOfService: LegalPage {
        LegalPage(
            kicker: "Terms",
            title: "Terms of Service",
            subtitle: "The basic rules for using e-z.rsvp, joining groups, and reserving mystery events.",
            updated: "June 2026",
            sections: [
                LegalSection(title: "Using e-z.rsvp", body: [
                    "e-z.rsvp helps users discover and RSVP to mystery events based on timing, budget, location radius, and broad preferences.",
                    "By using the service, you agree to provide accurate information, follow event rules, and use the platform responsibly.",
                ]),
                LegalSection(title: "Mystery-event details", body: [
                    "Some event details may remain hidden until the reveal window. You understand that the exact venue, event name, or activity may not be visible at the time you RSVP.",
                    "Event cards may show limited information such as price, remaining tickets, category, timing, safety notes, and reveal countdowns.",
                ]),
                LegalSection(title: "Payments and reservations", body: [
                    "Purchases may be processed through Stripe or another payment provider. Ticket prices, refunds, and cancellation windows may vary depending on event rules and organizer requirements.",
                    "A reservation is not guaranteed until the purchase or RSVP flow is completed successfully.",
                ]),
                LegalSection(title: "Groups and conduct", body: [
                    "Users may create groups, join groups with codes, leave groups, and share event plans with friends. You are responsible for how you use group codes and shared information.",
                    "You may not use e-z.rsvp to harass others, bypass event safety rules, misuse hidden venue information, or interfere with other users’ experiences.",
                ]),
            ]
        )
    }

    static var privacyPolicy: LegalPage {
        LegalPage(
            kicker: "Privacy",
            title: "Privacy Policy",
            subtitle: "A clear overview of what information e-z.rsvp uses to create safer, easier mystery-event experiences.",
            updated: "June 2026",
            sections: [
                LegalSection(title: "Information we collect", body: [
                    "When you use e-z.rsvp, we may collect information you provide directly, such as your name, email address, phone number, default address, category preferences, group choices, and RSVP activity.",
                    "We may also use approximate location or address information that you enter into filters so we can estimate which mystery events fall inside your selected radius.",
                ]),
                LegalSection(title: "How we use information", body: [
                    "We use your information to help you create an account, sign in, find events, RSVP, join groups, manage preferences, and receive event-related updates.",
                    "Location filters are used to calculate distance from available mystery-event locations. Hidden event addresses are not shown to users before reveal time.",
                ]),
                LegalSection(title: "Payments and third-party services", body: [
                    "If you purchase tickets, payment processing may be handled by Stripe. e-z.rsvp does not store full card numbers in the application.",
                    "Authentication may be handled through services like Google and Supabase. Those providers may process information according to their own policies.",
                ]),
                LegalSection(title: "Sharing and safety", body: [
                    "We do not sell personal information. We may share limited information with service providers only when needed to operate core app functionality, such as authentication, payments, hosting, analytics, or safety review.",
                    "We may use event, organizer, and account information to prevent abuse, investigate suspicious activity, and keep mystery-event experiences safe.",
                ]),
                LegalSection(title: "Your choices", body: [
                    "You can update account preferences from your account page. You can also log out, stop using the service, or request support related to account information.",
                ]),
            ]
        )
    }

    static var safetyTrust: LegalPage {
        LegalPage(
            kicker: "Safety",
            title: "Safety & Trust",
            subtitle: "Mystery should be fun, not risky. These are the principles behind the e-z.rsvp experience.",
            updated: "June 2026",
            sections: [
                LegalSection(title: "Public venues only", body: [
                    "e-z.rsvp is designed around public, established venues and experiences rather than private or unsafe locations.",
                    "Hidden details should never mean hidden risk. The goal is to preserve surprise while keeping core safety boundaries clear.",
                ]),
                LegalSection(title: "Verified organizer information", body: [
                    "Events can include organizer details, capacity limits, age requirements, safety notes, accessibility notes, and dress-code expectations.",
                    "Organizer and event information should be reviewed before experiences are made available to users.",
                ]),
                LegalSection(title: "Budget and distance boundaries", body: [
                    "Users can set maximum ticket price and location-radius preferences before RSVP. The app should respect those boundaries when matching events.",
                    "Internal event addresses may be used for distance calculations, while the user-facing location can remain hidden until reveal time.",
                ]),
                LegalSection(title: "Group transparency", body: [
                    "Groups help users coordinate with friends, see RSVP statuses, and plan shared mystery experiences.",
                    "Group codes should be shared only with people the group wants to invite.",
                ]),
                LegalSection(title: "Report concerns", body: [
                    "If something feels inaccurate, unsafe, or suspicious, users should contact support before attending the event.",
                    "For emergencies or immediate safety concerns, contact local emergency services first.",
                ]),
            ]
        )
    }

    static var support: LegalPage {
        LegalPage(
            kicker: "Help",
            title: "Support",
            subtitle: "Questions about an RSVP, ticket, group, account, or reveal? Start here.",
            updated: "June 2026",
            sections: [
                LegalSection(title: "Account help", body: [
                    "If you cannot sign in, try logging out fully, clearing old local session data, and signing in again with your chosen method.",
                    "For account updates, visit your account settings page to review name, email, phone, preferences, and category choices.",
                ]),
                LegalSection(title: "RSVP and ticket help", body: [
                    "If a ticket purchase does not complete, check whether the checkout page opened and whether the payment provider confirmed the transaction.",
                    "If the reveal countdown has ended but details are not visible, refresh the page or sign out and back in.",
                ]),
                LegalSection(title: "Group help", body: [
                    "Use Join with code to enter a group invite code. Group owners can manage or delete groups from the group detail overlay.",
                    "If group status looks wrong, ask members to refresh their RSVP or group page.",
                ]),
                LegalSection(title: "Contact support", body: [
                    "For any reports regarding concerns, venue issues, or product bugs, please send an email to ayaansaeedmalik@gmail.com and matthewma256@gmail.com.",
                ]),
            ]
        )
    }
}
