//
//  StretchCategoriesViewModel.swift
//  stretchApp
//
//  Created by Claude on 8/9/25.
//

import Foundation
import SwiftData
import SwiftUI

/// ViewModel for managing stretch categories data and state
@MainActor
final class StretchCategoriesViewModel: ObservableObject {
    
    // MARK: - Properties
    
    /// Model context for SwiftData operations
    private let modelContext: ModelContext
    
    /// Published properties for UI updates
    @Published var categories: [StretchCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Methods
    
    /// Load all stretch categories
    func loadCategories() async {
        print("🚀 Starting to load categories...")
        print("🔍 Current categories count: \(self.categories.count)")
        isLoading = true
        errorMessage = nil
        
        do {
            let descriptor = FetchDescriptor<StretchCategory>(
                sortBy: [SortDescriptor(\.name)]
            )
            
            let fetchedCategories = try modelContext.fetch(descriptor)
            print("📊 Found \(fetchedCategories.count) existing categories in database")
            
            // If no categories exist, create them from the JSON data
            if fetchedCategories.isEmpty {
                print("🆕 No categories found, creating from JSON...")
                await createCategoriesFromJSON()
                print("🔍 After creation, categories count: \(self.categories.count)")
            } else {
                print("✅ Using existing categories")
                self.categories = fetchedCategories
                print("🔍 After assignment, categories count: \(self.categories.count)")
            }
            
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            print("❌ Error loading categories: \(error)")
        }
        
        isLoading = false
        print("🏁 Finished loading categories. Final count: \(self.categories.count)")
    }
    
    /// Refresh categories data
    func refresh() async {
        await loadCategories()
    }
    
    // MARK: - Private Methods
    
        /// Create categories from the stretches.json file
    private func createCategoriesFromJSON() async {
        print("🔍 Creating categories from comprehensive JSON data...")
        
        // Create all 25 body part categories with their stretches
        let stretchData = [
            // Neck stretches
            ("Neck", "figure.flexibility", [
                ("Chin Tucks (Seated/Standing)", "Sit or stand tall. Gently draw your chin straight back, making a 'double chin' without tilting the head. Hold; keep shoulders relaxed and breathe.", 30),
                ("Upper Trapezius Stretch", "Sit tall. Tilt right ear toward right shoulder without lifting the shoulder. Use right hand lightly on the left side of head to deepen gently. Repeat other side.", 30),
                ("Levator Scapulae Stretch", "Turn head 45° to the right, then nod chin toward armpit. Use right hand gently on the back of the head to increase stretch. Repeat other side.", 30),
                ("Neck Rotation Hold", "Turn head slowly to look over right shoulder until a gentle stretch is felt; keep chin level. Hold, then repeat on the left.", 30),
                ("SCM Stretch", "Sit tall. Lift chest, tilt head back slightly and to the right, then gently look up/away to stretch the front-left neck. Repeat other side.", 30)
            ]),
            
            // Shoulders stretches
            ("Shoulders", "figure.strengthtraining.traditional", [
                ("Cross-Body Shoulder Stretch", "Bring right arm across chest at shoulder height. Use left forearm to draw right arm closer without pain. Keep shoulders down; breathe. Repeat sides.", 30),
                ("Doorway Pec Stretch (Goalpost)", "Stand in a doorway, elbows at 90° and forearms on the frame. Step one foot forward and lean body through until chest stretches. Keep ribs down.", 30),
                ("Posterior Capsule (Sleeper)", "Lie on right side, right shoulder and elbow at 90°. Use left hand to gently press right forearm toward floor to feel back-of-shoulder stretch. Repeat sides.", 30),
                ("Overhead Triceps Stretch", "Raise right arm overhead and bend elbow so hand reaches down the back. Use left hand to press elbow back and in. Keep ribs down; repeat other side.", 30),
                ("Thread the Needle (Hold)", "On hands and knees, slide right arm under left armpit, palm up, resting right shoulder and head on floor. Hips stacked. Hold; repeat other side.", 30)
            ]),
            
            // Upper Back stretches
            ("Upper Back", "figure.core.training", [
                ("Seated Thoracic Extension", "Sit with mid-back against chair backrest. Interlace fingers behind head, lift chest and gently arch upper back over the chair edge. Keep neck neutral.", 30),
                ("Child's Pose", "Kneel with big toes together, knees apart. Sit back toward heels and reach arms forward, lengthening through the spine. Relax shoulders and breathe.", 45),
                ("Thread the Needle (Thoracic)", "On hands and knees, slide right arm under chest with palm up, rotating thoracic spine. Rest shoulder/head. Keep hips stacked. Repeat other side.", 30),
                ("Wall Angels (Hold at End Range)", "Stand with back to wall, arms in goalpost. Keep ribs down. Slide arms up to a gentle end range and hold while keeping forearms/wrists near wall.", 30),
                ("Open Book (Static)", "Lie on left side, hips/knees bent 90°. Arms stacked. Rotate right arm across body to open chest, letting shoulders stack; keep knees together. Repeat sides.", 45)
            ]),
            
            // Lower Back stretches
            ("Lower Back", "figure.core.training", [
                ("Single Knee-to-Chest", "Lie on back. Bring one knee toward chest, hands behind thigh or on shin. Keep other leg straight or bent. Relax low back into floor; switch sides.", 30),
                ("Double Knee-to-Chest", "Lie on back, bring both knees toward chest and wrap arms around shins or behind thighs. Gently pull knees closer; relax neck and shoulders.", 30),
                ("Figure-4 Piriformis", "Lie on back, cross right ankle over left knee. Pull left thigh toward chest to feel right glute stretch. Keep tailbone heavy. Switch sides.", 45),
                ("Supine Lumbar Rotation", "Lie on back, arms out in a T. Knees bent together. Let knees drop to one side while shoulders stay down. Hold gently; switch sides.", 45),
                ("Child's Pose (Low Back Focus)", "Kneel and sit back on heels with knees hip-width. Reach arms forward and lengthen tailbone back, relaxing low back muscles. Breathe slowly.", 45)
            ]),
            
            // Hips stretches
            ("Hips", "figure.flexibility", [
                ("Half-Kneeling Hip Flexor", "Right knee down, left foot forward (lunge). Tuck pelvis (posterior tilt) and shift hips forward slightly until front of right hip stretches. Switch sides.", 30),
                ("Pigeon Pose (Modified)", "From hands/knees, bring right knee toward right wrist; shin angled. Slide left leg back. Keep chest lifted and spine long. Support hip with cushion if needed. Switch sides.", 45),
                ("90/90 Hip Stretch", "Sit with front leg bent 90° and back leg bent 90°. Keep spine tall and hinge over front shin for external rotation stretch. Switch sides.", 45),
                ("Butterfly (Groin)", "Sit tall, bring soles of feet together and let knees fall outward. Hold ankles, lengthen spine, and gently hinge forward from hips.", 45),
                ("Figure-4 Seated", "Sit tall on a chair, cross right ankle over left knee. Keep back straight and hinge slightly forward to feel right hip/glute stretch. Switch sides.", 45)
            ]),
            
            // Hamstrings stretches
            ("Hamstrings", "figure.flexibility", [
                ("Standing Hamstring Lean", "Place right heel on a low surface, knee soft. Hinge from hips keeping back neutral and toes up. Avoid rounding. Switch sides.", 30),
                ("Doorway Hamstring", "Lie near doorway and place right heel up the wall with knee nearly straight. Adjust distance to find mild tension. Keep other leg straight. Switch sides.", 45),
                ("Seated Strap/Towel Hamstring", "Sit tall with right leg extended. Loop towel around foot and gently draw toes toward you while hinging slightly forward from hips. Switch sides.", 45),
                ("Standing Step Hamstring", "Stand with right toes on a step, heel down. Hinge from hips with flat back until stretch felt along back of thigh. Switch sides.", 30),
                ("Supine Straight-Leg Raise with Strap", "Lie on back, loop strap around right foot. Keep left leg straight on floor. Raise right leg to a gentle hamstring stretch without lifting hips. Switch sides.", 45)
            ]),
            
            // Quads stretches
            ("Quads", "figure.flexibility", [
                ("Standing Quad Stretch", "Stand tall holding a wall/chair for balance. Bend right knee and hold right foot/ankle behind you. Knees together; tuck pelvis. Switch sides.", 30),
                ("Side-Lying Quad Stretch", "Lie on left side, grasp right ankle and draw heel toward glute. Keep thighs aligned, pelvis neutral. Avoid arching low back. Switch sides.", 30),
                ("Couch Stretch (Gentle)", "Kneel with right shin against wall or couch, right knee at base. Step left foot forward into lunge. Tuck pelvis and lift chest. Switch sides.", 45),
                ("Prone Quad with Strap", "Lie face down, loop strap around right ankle and draw heel toward glute. Keep hips level and pelvis neutral. Switch sides.", 30),
                ("Lunge Quad Focus", "From a lunge, drop back knee and shift hips forward while tucking pelvis to target front of thigh on back leg. Switch sides.", 30)
            ]),
            
            // Calves stretches
            ("Calves", "figure.flexibility", [
                ("Wall Calf Stretch (Gastrocnemius)", "Stand facing a wall. Step right leg back with knee straight, heel down. Lean into wall until upper calf stretches. Keep toes pointed forward. Switch sides.", 30),
                ("Wall Calf Stretch (Soleus)", "From the wall stance, bend the back (right) knee while keeping heel down to target lower calf (soleus). Maintain upright torso. Switch sides.", 30),
                ("Step Calf Drop", "Stand on a step with forefoot of right foot, heel hanging off. Lower heel below step level to a gentle stretch while holding a rail. Switch sides.", 30),
                ("Seated Towel Calf Stretch", "Sit with right leg extended. Loop towel around forefoot and gently pull toes toward you, keeping knee straight. Switch sides.", 30),
                ("Downward Dog (Static Calf Hold)", "From hands/feet, lift hips back and up. Press heels toward floor to feel calf stretch. Keep spine long and shoulders away from ears.", 45)
            ]),
            
            // Ankles stretches
            ("Ankles", "figure.flexibility", [
                ("Half-Kneeling Ankle Dorsiflexion", "Kneel with left knee down, right foot forward. Keeping heel down, drive right knee toward toes over middle toes to feel front-ankle stretch. Switch sides.", 30),
                ("Kneeling Shin (Anterior Tibialis) Stretch", "Kneel with toes pointed back and tops of feet on floor. Sit hips toward heels to feel front-of-shin stretch. Use hands for support as needed.", 30),
                ("Plantar Fascia Toe Stretch", "Sit and cross right leg over left. Pull back on right toes with hand to stretch arch/plantar fascia. Massage arch with thumb if desired. Switch sides.", 30),
                ("Achilles Tendon Wall Stretch", "Face a wall, step right foot back. Bend both knees slightly while keeping back heel down to target Achilles. Keep hips square. Switch sides.", 30),
                ("Tibialis Posterior Stretch (Inversion Bias)", "Seated, cross right ankle over left knee. Gently point foot and roll sole outward with hand to feel inside-ankle stretch. Gentle pressure only. Switch sides.", 30)
            ]),
            
            // Chest stretches
            ("Chest", "figure.flexibility", [
                ("Doorway Pec Stretch (Low)", "Place forearms on doorway slightly below shoulder height. Step forward and lean until a stretch is felt across the chest. Keep ribs down and neck long.", 30),
                ("Doorway Pec Stretch (High)", "Place forearms on doorway above shoulder height. Step forward and lean until the upper chest stretches. Avoid shrugging shoulders.", 30),
                ("Corner Chest Stretch", "Face into a corner with forearms on each wall. Step in and lean chest toward the corner to stretch both pecs evenly. Keep chin neutral.", 30),
                ("Supine Chest Opener (Towel Roll)", "Place a rolled towel lengthwise under the spine from mid-back to head. Rest arms out to sides in a T or goalpost and let chest open.", 60),
                ("Floor Angels (Hold at End Range)", "Lie on back, arms in goalpost. Slide arms toward overhead and pause at a gentle end range, keeping ribs down and low back neutral.", 30)
            ]),
            
            // Wrists stretches
            ("Wrists", "figure.flexibility", [
                ("Wrist Flexor Stretch", "Extend right arm forward, palm up. Gently pull fingers back with left hand until you feel a stretch along the inside of the forearm. Keep elbow straight. Switch sides.", 30),
                ("Wrist Extensor Stretch", "Extend right arm forward, palm down. Flex wrist and gently pull the back of the hand toward you with left hand to stretch top of forearm. Switch sides.", 30),
                ("Prayer Stretch", "Place palms together at chest in prayer position. Keeping palms pressed, slowly lower hands toward waist until a forearm/wrist stretch is felt.", 30),
                ("Reverse Prayer (Gentle)", "Place backs of hands together at waist (reverse prayer). Slowly lift hands up the spine as mobility allows to stretch wrists/forearms. Stay gentle.", 30),
                ("Finger & Thumb Stretch", "Extend right arm and gently pull back each finger and thumb one at a time, holding a light stretch and avoiding pain. Switch sides.", 30)
            ]),
            
            // Lats & Side Body stretches
            ("Lats & Side Body", "figure.flexibility", [
                ("Overhead Lat Stretch (Wall)", "Stand facing a wall, place both hands high on the wall shoulder-width. Hinge hips back and sink chest toward floor to stretch along the sides. Keep ribs down.", 30),
                ("Child's Pose with Side Reach", "From child's pose, walk both hands to the right to lengthen the left side body. Breathe into left ribs. Switch sides.", 45),
                ("Kneeling Bench Lat Stretch", "Place elbows/forearms on a bench, palms together. Kneel and sit hips back, letting chest drop. Keep core lightly braced; avoid lower-back sag.", 45),
                ("Single-Arm Doorframe Lat", "Hold doorframe overhead with right hand. Step right foot back and lean hips away to feel stretch along right side body. Switch sides.", 30),
                ("Seated Side Bend", "Sit tall, right hand on floor, left arm overhead. Arc left arm up and over to the right, breathing into left ribs. Switch sides.", 30)
            ]),
            
            // Quadratus Lumborum (QL) stretches
            ("Quadratus Lumborum (QL)", "figure.core.training", [
                ("Standing QL Reach", "Stand tall. Cross right foot behind left. Reach right arm overhead and lean left to feel stretch along right low back/side. Keep hips stacked. Switch sides.", 30),
                ("Doorway Side Lean", "Stand beside a doorway and hold frame with right hand at shoulder height. Step feet together and gently lean hips away from arm to open right side waist. Switch sides.", 30),
                ("Child's Pose with Hip Shift", "From child's pose, shift hips toward the right heels to bias left QL. Reach hands slightly left. Breathe slowly. Switch sides.", 45),
                ("Seated Figure-4 Side Fold", "Sit cross-legged with right ankle over left knee (figure-4). Side-bend torso toward right shin to bias left QL. Gentle, then switch sides.", 30),
                ("Wall Side Stretch (Forearm)", "Stand side-on to a wall, right forearm on wall above shoulder height. Lean torso away keeping pelvis level to feel right side waist stretch. Switch sides.", 30)
            ]),
            
            // Abdominals stretches
            ("Abdominals", "figure.core.training", [
                ("Sphinx Hold", "Lie on stomach, forearms under shoulders. Lift chest into a gentle backbend while keeping pelvis heavy. Avoid pinching low back; breathe.", 30),
                ("Prone Press-Up (Gentle Cobra)", "From prone, place hands near ribs and gently press the upper body up, keeping hips on floor. Stop at mild abdominal stretch; breathe evenly.", 20),
                ("Standing Back Extension (Hands Hips)", "Stand with hands on hips. Engage glutes and gently extend upper body backward to feel a light front-body stretch. Keep range gentle.", 15),
                ("Side-Lying Open Arm Stretch", "Lie on left side, knees bent. Reach right arm up and slightly back to open front body without compressing lower back. Switch sides.", 30),
                ("Bridge with Chest Lift (Isometric)", "Lie on back, knees bent. Lift hips into a gentle bridge while reaching arms overhead to lengthen front body. Keep ribs down and breathe.", 25)
            ]),
            
            // Glutes stretches
            ("Glutes", "figure.flexibility", [
                ("Seated Figure-4 (Chair)", "Sit tall on chair, cross right ankle over left knee. Hinge forward slightly to feel right glute stretch. Keep back long. Switch sides.", 45),
                ("Pigeon Pose (Supported)", "From all fours, bring right knee toward right wrist; shin angled. Slide left leg back. Support right hip with cushion to stay level. Switch sides.", 45),
                ("Supine Figure-4 Pull", "Lie on back, cross right ankle over left knee and pull left thigh toward chest to target right glute. Keep tailbone heavy. Switch sides.", 45),
                ("Standing Glute Cross-Over", "Stand tall, cross right ankle over left knee and sit into a mini single-leg squat while keeping chest lifted. Hold chair for balance. Switch sides.", 30),
                ("Quadruped Sit-Back (Glute Bias)", "From hands/knees, widen knees slightly and sit hips back toward heels, keeping spine long. Focus on glute lengthening. Breathe.", 45)
            ]),
            
            // Adductors (Inner Thigh) stretches
            ("Adductors (Inner Thigh)", "figure.flexibility", [
                ("Butterfly (Seated Groin)", "Sit tall, bring soles of feet together. Hold ankles and gently hinge forward from hips, letting knees drop outward. Keep spine long.", 45),
                ("Half-Kneeling Adductor Rockback", "Kneel, extend right leg out to the side with foot flat and toes forward. Hinge hips back to feel inner thigh stretch. Switch sides.", 45),
                ("Side Lunge Hold", "Stand with feet wide. Shift hips over to the right into a side lunge while keeping left leg straight and toes forward. Hold; switch sides.", 30),
                ("Frog Pose (Gentle)", "On hands/forearms and knees wide, shins in line with thighs. Gently shift hips back to a mild inner-thigh stretch; keep core braced.", 30),
                ("Seated Straddle Side Reach", "Sit in a comfortable straddle. Reach both hands toward right foot while keeping spine long to bias inner left thigh. Switch sides.", 45)
            ]),
            
            // Hip Rotators stretches
            ("Hip Rotators", "figure.flexibility", [
                ("90/90 External Rotation (Front)", "Sit with right leg in front at 90° and left leg behind at 90°. Keep spine tall and hinge over front shin for an external rotator stretch. Switch sides.", 45),
                ("90/90 Internal Rotation (Back)", "From 90/90, rotate torso toward the back-leg side and hinge slightly to target internal rotation on the back hip. Switch sides.", 45),
                ("Seated Piriformis (Cross-Over)", "Sit tall, cross right leg over left so foot is outside left knee. Hug right knee toward chest and keep spine long. Switch sides.", 45),
                ("Supine Windshield Wipers", "Lie on back with knees bent and feet wide. Let knees drop side to side together, pausing briefly at end range to open hips.", 30),
                ("Standing Figure-4 Lean", "Stand holding a chair, cross right ankle over left knee and hinge forward from hips keeping back straight to bias right deep rotators. Switch sides.", 30)
            ]),
            
            // TFL / Lateral Thigh stretches
            ("TFL / Lateral Thigh", "figure.flexibility", [
                ("Standing Lateral Hip Lean", "Stand tall. Cross right leg behind left and shift hips to the right while leaning torso left to target right lateral hip (TFL). Switch sides.", 30),
                ("Side-Lying Quad with Hip Bias", "Lie on left side, grab right ankle behind you. Slightly draw knee back and across behind the body to feel along outer front hip. Gentle. Switch sides.", 30),
                ("Wall Lean TFL Bias", "Stand with right hip near a wall. Cross right foot behind left and press right hip gently toward wall while reaching right arm overhead. Switch sides.", 30),
                ("Figure-4 Against Wall (Shin Vertical)", "Lie near wall with shins up. Cross right ankle over left knee and inch hips closer to wall to feel outer hip/lateral thigh. Switch sides.", 45),
                ("Standing Step-Behind Reach", "Step right foot behind and across left, reach right arm overhead and lean left to open right lateral hip line. Keep pelvis level. Switch sides.", 30)
            ]),
            
            // Forearms stretches
            ("Forearms", "figure.flexibility", [
                ("Forearm Flexor Wall Stretch", "Place right palm on wall at shoulder height, fingers down. Gently straighten elbow and rotate body away to stretch inner forearm. Switch sides.", 30),
                ("Forearm Extensor Wall Stretch", "Place back of right hand on wall, fingers down. Straighten elbow gently and rotate body away to target top of forearm. Switch sides.", 30),
                ("Tabletop Palm-Up Rock", "On hands/knees with palms up and fingers pointing toward knees, gently rock hips back until a mild stretch is felt along forearms. Small range.", 30),
                ("Prayer to Reverse Prayer Flow (Hold Ends)", "Move from prayer stretch to reverse prayer behind back, pausing 15s at each end range to open wrists/forearms. Stay gentle.", 30),
                ("Finger Extensor Glide", "Extend right arm, palm down. Use left hand to flex right wrist and curl fingers under slightly to bias finger extensors. Switch sides.", 30)
            ]),
            
            // Hands & Fingers stretches
            ("Hands & Fingers", "figure.flexibility", [
                ("Thumb Abductor Stretch", "With left hand, gently pull right thumb away from palm (as if opening a jar) to stretch base of thumb. Keep wrist neutral. Switch sides.", 20),
                ("Finger Webbing Stretch", "Interlace fingers and gently open hands to spread finger webbing. Keep shoulders relaxed and breathe evenly.", 20),
                ("Palm Stretch (Desk Edge)", "Place right palm on desk edge with fingers pointing back. Gently lean body weight to open palm/thenar. Keep elbow soft. Switch sides.", 20),
                ("Claw to Flat Hand Holds", "Make a gentle claw with fingers, hold, then open to a flat hand splay. Alternate 10s each to mobilize small hand tissues.", 20),
                ("Tendon Glides (Sequence Hold)", "Move through straight hand → hook fist → full fist → straight fist, holding 5s each position with smooth breathing.", 20)
            ]),
            
            // Feet & Toes stretches
            ("Feet & Toes", "figure.flexibility", [
                ("Toe Extension on Wall", "Stand facing a wall, place right toes up the wall with ball of foot on floor. Gently lean in to stretch toes/forefoot. Switch sides.", 30),
                ("Plantar Fascia Roll & Hold", "Seated or standing, roll a ball under arch for 30s then hold on the most tender spot for 10–15s. Switch sides.", 45),
                ("Big Toe Flexion Stretch", "Seated, cross right ankle over left knee. Gently bend big toe down (plantar flex) with hand to open top of big toe joint. Switch sides.", 20),
                ("Toe Squat (Modified)", "Kneel with toes tucked under, sit hips back toward heels to stretch soles. Use hands on floor to unload pressure as needed. Gentle.", 30),
                ("Ankle/Toe Point & Spread", "Seated, point and flex ankle while spreading toes wide at end range. Hold brief 3–5s at each end to lengthen foot tissues.", 30)
            ])
        ]
        
        for (bodyPart, iconName, stretches) in stretchData {
            let category = StretchCategory(
                name: bodyPart,
                iconName: iconName,
                stretchCount: stretches.count,
                isPremium: false
            )
            
            // Create exercises for this category
            for (index, (name, instruction, duration)) in stretches.enumerated() {
                // First stretch is free, rest require premium
                let isPremium = index > 0
                
                let exercise = StretchExercise(
                    exerciseNumber: index + 1,
                    name: name,
                    instruction: instruction,
                    stretchTimeSec: duration,
                    category: category,
                    isPremium: isPremium
                )
                
                category.stretches.append(exercise)
                modelContext.insert(exercise)
            }
            
            modelContext.insert(category)
        }
        
        // Save to database
        do {
            try modelContext.save()
            print("💾 Saved comprehensive JSON-based categories to database")
            
            // Fetch the categories we just created
            let descriptor = FetchDescriptor<StretchCategory>(
                sortBy: [SortDescriptor(\.name)]
            )
            self.categories = try modelContext.fetch(descriptor)
            print("🔄 Fetched \(self.categories.count) categories after creation")
            
        } catch {
            errorMessage = "Failed to save comprehensive JSON-based categories: \(error.localizedDescription)"
            print("❌ Error saving comprehensive JSON-based categories: \(error)")
        }
    }
}

// MARK: - Stretch Data Structure

/// Data structure for decoding the stretches.json file
struct StretchData: Codable {
    let bodyPart: String
    let stretchNumber: Int
    let stretchName: String
    let instruction: String
    let stretchTimeSec: Int
}
