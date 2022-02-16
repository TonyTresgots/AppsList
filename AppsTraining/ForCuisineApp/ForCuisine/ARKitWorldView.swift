import SwiftUI
import RealityKit
import ARKit
import Vision

var mealGen = Dish(name: "", image: "", cuisine: "", course: "", ingredients: "", allergicContent: "", description: "", price: 12, story: "", restaurant: "", usdzModel: "chicken_meal", frontpage: true)

struct ARKitWorldView: View {
    @State var meal : Dish
    
    func loadMeal() {
        mealGen = self.meal
    }
    
    var body: some View {
        VStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)
        }.onAppear {
            self.loadMeal()
        }
    }
}

struct ARViewContainer: UIViewRepresentable {

    func makeUIView(context: Context) -> ARView {

        let arView = FoodObjARView(frame: .zero)
        arView.addCoaching()

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])

        arView.setupGestures()
        arView.session.delegate = arView

        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {

    }
}

class FoodObjARView: ARView, ARSessionDelegate {
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)

    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {

        guard let touchInView = sender?.location(in: self) else {
            return
        }

        let entities = self.entities(at: touchInView)

        if entities.isEmpty {
            rayCastingMethod(point: touchInView)
        }
    }

    func rayCastingMethod(point: CGPoint) {

        guard let raycastQuery = self.makeRaycastQuery(from: point,
                                                       allowing: .existingPlaneInfinite,
                                                       alignment: .horizontal) else {

                                                        print("failed first")
                                                        return
        }

        guard let result = self.session.raycast(raycastQuery).first else {
            print("failed")
            return
        }

        let transformation = Transform(matrix: result.worldTransform)

        let raycastAnchor = AnchorEntity(raycastResult: result)

        var model : ModelEntity!
        let boxAnchor = try! Experience.loadBox()
        boxAnchor.generateCollisionShapes(recursive: true)

        do {
            model = try ModelEntity.loadModel(named: mealGen.usdzModel ?? "")
            model.scale = SIMD3<Float>(0.1, 0.1, 0.1)
            model.position = boxAnchor.model!.position

        } catch {
            fatalError()
        }

        boxAnchor.addChild(model)
        boxAnchor.transform = transformation

        let nameTextEntity = boxAnchor._name?.children.first?.children.first?.components

        var textModelName: ModelComponent = (nameTextEntity![ModelComponent])!

        var material1 = SimpleMaterial()
        material1.baseColor = .color(.white)
        textModelName.materials[0] = material1

        textModelName.mesh = .generateText(mealGen.name,
                                           extrusionDepth: 0.01,
                                           font: .systemFont(ofSize: 0.08),
                                           containerFrame: CGRect(),
                                           alignment: .center,
                                           lineBreakMode: .byCharWrapping)

        let descTextEntity = boxAnchor.descCard?.children.first?.children.first?.components

        var textModelDesc: ModelComponent = (descTextEntity![ModelComponent])!

        var material2 = SimpleMaterial()
        material2.baseColor = .color(.white)
        textModelDesc.materials[0] = material2

        textModelDesc.mesh = .generateText(String(charsPerLine: 30, "Description : \n" + mealGen.description),       // change
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.08),
            containerFrame: CGRect(),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let priceTextEntity = boxAnchor.priceCard?.children.first?.children.first?.components

        var textModelPrice: ModelComponent = (priceTextEntity![ModelComponent])!

        var material3 = SimpleMaterial()
        material3.baseColor = .color(.white)
        textModelPrice.materials[0] = material3

        textModelPrice.mesh = .generateText("Price : \(mealGen.price)€",
                                            extrusionDepth: 0.01,
                                            font: .systemFont(ofSize: 0.08),
                                            containerFrame: CGRect(),
                                            alignment: .center,
                                            lineBreakMode: .byCharWrapping)

        let othersTextEntity = boxAnchor.otherCard?.children.first?.children.first?.components

        var textModelOthers: ModelComponent = (othersTextEntity![ModelComponent])!

        var material4 = SimpleMaterial()
        material4.baseColor = .color(.white)
        textModelOthers.materials[0] = material4

        let aString: String = mealGen.ingredients
        let newString = aString.replacingOccurrences(of: ", ", with: "\n")

        textModelOthers.mesh = .generateText("Ingredients : \n" + newString,
                                             extrusionDepth: 0.01,
                                             font: .systemFont(ofSize: 0.08),
                                             containerFrame: CGRect(),
                                             alignment: .center,
                                             lineBreakMode: .byCharWrapping)

        model.setPosition(SIMD3<Float>(0, 0.05, 0), relativeTo: boxAnchor)
        model.setOrientation(simd_quatf(ix: 0, iy: 0, iz: 0, r: 180), relativeTo: boxAnchor)

        boxAnchor.descCard?.children.first?.children.first?.components.set(textModelDesc)
        boxAnchor.priceCard?.children.first?.children.first?.components.set(textModelPrice)
        boxAnchor.otherCard?.children.first?.children.first?.components.set(textModelOthers)
        boxAnchor._name?.children.first?.children.first?.components.set(textModelName)

        boxAnchor._name?.children.first?.children.first?.setPosition(SIMD3<Float>(-0.25, -0.035, 0), relativeTo: boxAnchor._name?.children.first)
        boxAnchor.priceCard?.children.first?.children.first?.setPosition(SIMD3<Float>(-0.20, -0.035, 0), relativeTo: boxAnchor.priceCard?.children.first)
        boxAnchor.otherCard?.children.first?.children.first?.setPosition(SIMD3<Float>(-0.22, -0.400, 0), relativeTo: boxAnchor.otherCard?.children.first)
        boxAnchor.descCard?.children.first?.children.first?.setPosition(SIMD3<Float>(-0.50, -0.580, 0), relativeTo: boxAnchor.descCard?.children.first)

        raycastAnchor.addChild(boxAnchor)
        self.scene.addAnchor(raycastAnchor)
    }
}


extension ARView {

}

extension ARView: ARCoachingOverlayViewDelegate {

    func addCoaching() {

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlayView.activatesAutomatically = false
        //Ready to add objects
    }

}

struct ARKitWorldView_Previews: PreviewProvider {
    static var previews: some View {
        ARKitWorldView(meal: Dish(name: "TJTT", image: "", cuisine: "", course: "", ingredients: "", allergicContent: "", description: "", price: 12, story: "", restaurant: "", usdzModel: "chicken_meal", frontpage: true))
    }
}

