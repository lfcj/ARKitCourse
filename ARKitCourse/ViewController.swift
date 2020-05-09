import ARKit
import CoreMotion
import UIKit

class ViewController: UIViewController {

    // MARK: - Nested Types

    enum Section: CaseIterable {
        // Fundamentals + makeHouse
        case section3
        // Draw app
        case section4
        // Solar system
        case section5
        // Jellyfish
        case section6
        // Lava Floor
        case section7
        // Ikea
        case section8
        // Vehicle
        case section9
        // Measure Distances
        case section10
        // AR Portal
        case section11
        // Basketball
        case section12

        var name: String {
            switch self {
            case .section3:
                return "Make House"
            case .section4:
                return "Drawing app"
            case .section5:
                return "Solar System"
            case .section6:
                return "Jellyfish game"
            case .section7:
                return "Floor is lava"
            case .section8:
                return "Ikea"
            case .section9:
                return "Vehicle"
            case .section10:
                return "Measuring"
            case .section11:
                return "AR Portal"
            case .section12:
                return "Basketball Court"
            }
        }
    }

    // MARK: - Outlets

    @IBOutlet private var sceneView: ARSCNView!
    @IBOutlet private var sectionPickerView: UIPickerView!
    @IBOutlet private var leftButton: UIButton!
    @IBOutlet private var rightButton: UIButton!
    @IBOutlet private var middleButton: UIButton!
    @IBOutlet private var topLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var sceneViewBottomToCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet private var measurementsStackView: UIStackView!
    @IBOutlet private var diagonalDistanceLabel: UILabel!
    @IBOutlet private var xDistanceLabel: UILabel!
    @IBOutlet private var yDistanceLabel: UILabel!
    @IBOutlet private var zDistanceLabel: UILabel!
    @IBOutlet private var plusButton: UIButton!
    
    // MARK: - Properties

    private let configuration = ARWorldTrackingConfiguration()
    private let motionManager = CMMotionManager()
    private var rootNodeChildrenNames = [String]()
    private var currentSection = Section.section12 {
        didSet {
            configureCurrentSection()
            removeAllTapRecognizers()
            restartSession()
            makeSolarSystem()
        }
    }

    // MARK: - Jellyfish Properties

    private var countdown = 10
    private var timer: Timer?

    // MARK: - IKEA Properties

    private let ikeaItems: [String] = ["cup", "vase", "boxing", "table"]
    private var selectedIkeaItem: String?

    // MARK: - Vehicle Properties

    private var vehicle = SCNPhysicsVehicle()
    private var orientation: CGFloat = 0
    private var userDidTouchScreen = false
    private var userTouches: Int = 0
    private var accelerationValues: [Double] = [0, 0]

    // MARK: - Measurement Properties

    var startingPosition: SCNNode?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sectionPickerView.dataSource = self
        sectionPickerView.delegate = self
        configureCurrentSection()
        setUpAccelerometer()
        if let sectionIndex = Section.allCases.firstIndex(of: currentSection) {
            sectionPickerView.selectRow(sectionIndex, inComponent: 0, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeSolarSystem()
    }

    // MARK: - Overridden Methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !touches.isEmpty else {
            return
        }
        // If user touched with 2 fingers, the count will be 2
        userTouches += touches.count
        userDidTouchScreen = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        userTouches = 0
        userDidTouchScreen = false
    }

    // MARK: - Actions

    @IBAction func didTapLeftButton(_ sender: Any) {
        switch currentSection {
        case .section3:
            makeHouse()
        case .section6:
            setTimer()
            addJellyfish()
            leftButton.isEnabled = false
        case .section9:
            addCar()
        default:
            break
        }
    }

    @IBAction func didTapMiddleButton(_ sender: Any) {
    }

    @IBAction func didTapRightButton(_ sender: Any) {
        switch currentSection {
        case .section3, .section9:
            restartSession()
        case .section6:
            timer?.invalidate()
            timer = nil
            resetJellyfishLabel()
            restartSession()
            leftButton.isEnabled = true
        default:
            break
        }
    }

}

// MARK: - Configuration

private extension ViewController {

    func configureCurrentSection() {
        configureSection3(isHidden: true)
        configureSection4(isHidden: true)
        configureSection5(isHidden: true)
        configureSection6(isHidden: true)
        configureSection7(isHidden: true)
        configureSection8(isHidden: true)
        configureSection9(isHidden: true)
        configureSection10(isHidden: true)
        configureSection11(isHidden: true)
        configureSection12(isHidden: true)

        switch currentSection {
        case .section3:
            configureSection3(isHidden: false)
        case .section4:
            configureSection4(isHidden: false)
        case .section5:
            configureSection5(isHidden: false)
        case .section6:
            configureSection6(isHidden: false)
        case .section7:
            configureSection7(isHidden: false)
        case .section8:
            configureSection8(isHidden: false)
        case .section9:
            configureSection9(isHidden: false)
        case .section10:
            configureSection10(isHidden: false)
        case .section11:
            configureSection11(isHidden: false)
        case .section12:
            configureSection12(isHidden: true)
        }
        sceneView.session.run(configuration)
    }

    func configureSection3(isHidden: Bool) {
        [leftButton, rightButton].forEach { $0?.isHidden = isHidden }
        guard !isHidden else {
            return
        }
        leftButton.setImage(nil, for: .normal)
        rightButton.setImage(nil, for: .normal)
        
        sceneView.autoenablesDefaultLighting = !isHidden
    }

    func configureSection4(isHidden: Bool) {
        [leftButton, rightButton].forEach { $0?.isHidden = !isHidden }
        middleButton.isHidden = isHidden
        sceneView.showsStatistics = !isHidden
        sceneView.delegate = self
    }

    func configureSection5(isHidden: Bool) {
        sceneView.autoenablesDefaultLighting = !isHidden
        [leftButton, rightButton].forEach { $0?.isHidden = !isHidden}
    }
    func configureSection6(isHidden: Bool) {
        topLabel.isHidden = isHidden
        [leftButton, rightButton].forEach { $0?.isHidden = isHidden }
        guard !isHidden else {
            return
        }
        [leftButton, rightButton].forEach { button in
            button?.setTitle(nil, for: .normal)
            button?.backgroundColor = nil
            button?.tintColor = nil
        }
        leftButton.setImage(#imageLiteral(resourceName: "6_jellyfish/Play"), for: .normal)
        rightButton.setImage(#imageLiteral(resourceName: "6_jellyfish/Reset"), for: .normal)
        resetJellyfishLabel()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleJellyfishTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    func configureSection7(isHidden: Bool) {
        guard !isHidden else {
            return
        }
        configuration.planeDetection = .horizontal
        sceneView.delegate = self
    }

    func configureSection8(isHidden: Bool) {
        collectionView.isHidden = isHidden
        sceneViewBottomToCollectionViewConstraint.isActive = !isHidden
        guard !isHidden else {
            return
        }
        sceneView.autoenablesDefaultLighting = true
        collectionView.dataSource = self
        collectionView.delegate = self
        configuration.planeDetection = .horizontal

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleIkeaTap))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotateNode))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        sceneView.addGestureRecognizer(longPressGestureRecognizer)
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    func configureSection9(isHidden: Bool) {
        [leftButton, rightButton].forEach { $0?.isHidden = isHidden }
        guard !isHidden else {
            return
        }
        leftButton.setImage(nil, for: .normal)
        rightButton.setImage(nil, for: .normal)
        leftButton.setTitle("Add", for: .normal)
        rightButton.setTitle("Reset", for: .normal)
        configuration.planeDetection = .horizontal
        sceneView.delegate = self
    }

    func configureSection10(isHidden: Bool) {
        measurementsStackView.isHidden = isHidden
        plusButton.isHidden = isHidden
        guard !isHidden else {
            return
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMeasurementTap(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        middleButton.setTitle("Add", for: .normal)
    }

    func configureSection11(isHidden: Bool) {
        guard !isHidden else {
            return
        }
        sceneView.delegate = self
        configuration.planeDetection = .horizontal
        topLabel.font = .boldSystemFont(ofSize: 25)
        topLabel.text = "Plane Detected"
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePortalTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    func configureSection12(isHidden: Bool) {
        plusButton.isHidden = isHidden
        guard !isHidden else {
            return
        }
        sceneView.automaticallyUpdatesLighting = true
    }

}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard .section4 == currentSection else {
            return
        }
        renderDrawing()
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        switch currentSection {
        case .section7:
            handlePlaneDidAdd(node: node, for: anchor, childNode: makeLavaNode(for: anchor))
        case .section8:
            handlePlaneDidAdd(node: node, for: anchor)
        case .section9:
            handlePlaneDidAdd(node: node, for: anchor, childNode: makeConcreteNode(for: anchor))
        case .section11:
            handlePlaneDidAdd(node: node, for: anchor)
        default:
            break
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        switch currentSection {
        case .section7:
            handlePlaneDidUpdate(node: node, for: anchor, childNode: makeLavaNode(for: anchor))
        case .section9:
            handlePlaneDidUpdate(node: node, for: anchor, childNode: makeConcreteNode(for: anchor))
        default:
            break
        }
    }

    /// It is called when the device makes a mistake and adds something it should have not
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        switch currentSection {
        case .section7, .section9:
            handlePlaneDidRemove(node: node, for: anchor)
        default:
            break
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        handleUpdateAtTime()
    }

    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        handleDidSimulatePhysics()
    }

}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Section.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Section.allCases[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSection =  Section.allCases[row]
    }
    
}

// MARK: - Section 3 - House

private extension ViewController {

    func makeHouse() {
        let doorNode = SCNNode(geometry: SCNPlane(width: 0.03, height: 0.06))
        setDiffuse(.brown, to: doorNode)

        let boxNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        setDiffuse(.blue, to: boxNode)

        let node = SCNNode()
        node.geometry = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)
        setDiffuse(.orange, to: node)
        setSpecular(.red, to: node)
        node.position = SCNVector3(0.2,0.3,-0.2)

        // Rotation
        node.eulerAngles = SCNVector3(Float(180.degreesToRadians),0,0)

        boxNode.position = SCNVector3(0, -0.05, 0)
        doorNode.position = SCNVector3(0,-0.02,0.053)

        node.name = "house-roof"
        rootNodeChildrenNames.append("house-roof")

        sceneView.scene.rootNode.addChildNode(node)
        node.addChildNode(boxNode)
        boxNode.addChildNode(doorNode)
    }

    func restartSession() {
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if let nodeName = node.name, rootNodeChildrenNames.contains(nodeName) {
                node.removeFromParentNode()
            }
        }
        sceneView.session.pause()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func removeAllTapRecognizers() {
        for recognizer in sceneView.gestureRecognizers ?? [] {
            sceneView.removeGestureRecognizer(recognizer)
        }
    }

}

// MARK: - Section 4 - Drawing

extension ViewController {

    func renderDrawing() {
        guard let pointOfView = sceneView.pointOfView else {
            return
        }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let frontOfCamera = orientation + location
        DispatchQueue.main.async { [weak self] in
            if self?.middleButton.isHighlighted == true {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = frontOfCamera

                sphereNode.name = "drawing-sphere"
                self?.rootNodeChildrenNames.append("drawing-sphere")

                self?.sceneView.scene.rootNode.addChildNode(sphereNode)
                self?.setDiffuse(.red, to: sphereNode)
            }
            else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                self?.rootNodeChildrenNames.append("pointer")
                pointer.position = frontOfCamera
                self?.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                })
                self?.sceneView.scene.rootNode.addChildNode(pointer)
                self?.setDiffuse(.red, to: pointer)
            }

        }
    }

}

// MARK: - Section 5 - Solar System

private extension ViewController {

    func makeSolarSystem() {
        guard .section5 == currentSection else {
            return
        }
        let sun = makeSun()
        let earth = makeEarth()
        let venus = makeVenus()

        earth.position = sun.position
        venus.position = sun.position

        sun.name = "sun"
        earth.name = "earth"
        venus.name = "venus"

        rootNodeChildrenNames.append(contentsOf: ["sun", "earth", "venus"])

        sceneView.scene.rootNode.addChildNode(sun)
        sceneView.scene.rootNode.addChildNode(earth)
        sceneView.scene.rootNode.addChildNode(venus)
    }

    func makeEarth() -> SCNNode {
        let earthParent = SCNNode()
        let earth = makePlanet(
            geometry: SCNSphere(radius: 0.2),
            diffuse: #imageLiteral(resourceName: "5_Solar system/Earth day"),
            specular: #imageLiteral(resourceName: "5_Solar system/Earth Specular"),
            emission: #imageLiteral(resourceName: "5_Solar system/Earth Emission"),
            normal: #imageLiteral(resourceName: "5_Solar system/Earth Normal"),
            position: SCNVector3(1.2 ,0 , 0))

        earthParent.runAction(makeForeverRotation(duration: 14))
        earthParent.addChildNode(earth)
        earth.runAction(makeForeverRotation(duration: 8))
        let moon = makeMoon()
        moon.position = SCNVector3(1.2 ,0 , 0)
        earthParent.addChildNode(moon)
        return earthParent
    }

    func makeMoon() -> SCNNode {
        let moonParent = SCNNode()
        let moon = makePlanet(
            geometry: SCNSphere(radius: 0.05),
            diffuse: #imageLiteral(resourceName: "5_Solar system/moon Diffuse"),
            specular: nil,
            emission: nil,
            normal: nil,
            position: SCNVector3(0,0,-0.3))
        moonParent.runAction(makeForeverRotation(duration: 5))
        moonParent.addChildNode(moon)
        return moonParent
    }

    func makeSun() -> SCNNode {
        let sun = SCNNode(geometry: SCNSphere(radius: 0.35))
        setDiffuse(#imageLiteral(resourceName: "5_Solar system/Sun diffuse"), to: sun)
        sun.position = SCNVector3(0,0,-2)
        sun.runAction(makeForeverRotation(duration: 8))
        return sun
    }

    func makeVenus() -> SCNNode {
        let venusParent = SCNNode()
        let venus = makePlanet(
            geometry: SCNSphere(radius: 0.1),
            diffuse: #imageLiteral(resourceName: "5_Solar system/Venus Surface"),
            specular: nil,
            emission: #imageLiteral(resourceName: "5_Solar system/Venus Atmosphere"),
            normal: nil,
            position: SCNVector3(0.7, 0, 0))
        venusParent.runAction(makeForeverRotation(duration: 10))
        venusParent.addChildNode(venus)
        venus.runAction(makeForeverRotation(duration: 8))
        return venusParent
    }

    func makePlanet(
        geometry: SCNGeometry,
        diffuse: UIImage,
        specular: UIImage?,
        emission: UIImage?,
        normal: UIImage?,
        position: SCNVector3) -> SCNNode
    {
        let planet = SCNNode(geometry: geometry)
        setDiffuse(diffuse, to: planet)
        setSpecular(specular, to: planet)
        setEmission(emission, to: planet)
        setNormal(normal, to: planet)
        planet.position = position
        return planet
    }

}

// MARK: - Section 6 - Jellyfish

private extension ViewController {

    func addJellyfish() {
        let jellyFishNodeName = "Jellyfish"
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyfishNode = jellyFishScene?.rootNode.childNode(withName: jellyFishNodeName, recursively: false)
        jellyfishNode?.position = makeRandomVector()
        jellyfishNode?.name = jellyFishNodeName
        rootNodeChildrenNames.append(jellyFishNodeName)
        sceneView.scene.rootNode.addChildNode(jellyfishNode!)
    }

    @objc func handleJellyfishTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("didn't touch anything")
        } else if countdown > 0 {
            let results = hitTest.first!
            let node = results.node

            guard node.animationKeys.isEmpty else {
                return
            }

            // The SCNTransaction makes sure that the animation is completed
            // before the jellyfish is removed
            SCNTransaction.begin()
            self.animateNode(node: node)
            SCNTransaction.completionBlock = { [weak self] in
                node.removeFromParentNode()
                self?.removeJellyfishes()
                self?.addJellyfish()
                self?.restoreTimer()
            }
            SCNTransaction.commit()
        }
    }

    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(
            node.presentation.position.x - 0.2,
            node.presentation.position.y - 0.2 ,
            node.presentation.position.z - 0.2)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
    }

    func setTimer() {
        countdown = 10
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                return
            }
            self.countdown -= 1
            self.topLabel.text = String(self.countdown)

            if self.countdown <= 0 {
                self.topLabel.text = "You lose"
                timer.invalidate()
            }
        }
    }

    func restoreTimer() {
        countdown = 10
        topLabel.text = String(countdown)
    }

    func resetJellyfishLabel() {
        topLabel.text = "Start playing"
    }

    func removeJellyfishes() {
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if let nodeName = node.name, nodeName == "Jellyfish" {
                node.removeFromParentNode()
            }
        }
    }

}

// MARK: - Section 7 - Plane Detection

private extension ViewController {

    func handlePlaneDidAdd(node: SCNNode, for anchor: ARAnchor, childNode: SCNNode?) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        print ("New plane service detected, new ARPlaneAnchor added")
        if let childNode = childNode {
            node.addChildNode(childNode)
        }
    }

    func handlePlaneDidUpdate(node: SCNNode, for anchor: ARAnchor, childNode: SCNNode?) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        print ("Updating floor's anchor")
        node.enumerateChildNodes { (childNode, _) in
            // Have to remove it cuz we want to update the anchor size and it is a let constant
            childNode.removeFromParentNode()
        }
        if let childNode = childNode {
            node.addChildNode(childNode)
        }
    }

    func handlePlaneDidRemove(node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        node.enumerateChildNodes { (childNode, _) in
            // Remove plane node
            childNode.removeFromParentNode()
        }
    }

    func makeLavaNode(for anchor: ARAnchor) -> SCNNode? {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return nil
        }
        let lavaNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        setDiffuse(#imageLiteral(resourceName: "7_Lava Floor/lava"), to: lavaNode)
        lavaNode.position = planeAnchor.position
        // Make sure one can see the lava from both sides
        lavaNode.geometry?.firstMaterial?.isDoubleSided = true
        lavaNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        return lavaNode
    }

}

// MARK: - Section 8 - IKEA

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ikeaItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! IkeaItemCollectionViewCell
        cell.configure(itemName: ikeaItems[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        selectedIkeaItem = ikeaItems[indexPath.row]
        cell.backgroundColor = .systemGreen
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        selectedIkeaItem = nil
        cell.backgroundColor = .systemOrange
    }

    @objc func handleIkeaTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {
            return
        }
        // where did user tap?
        let tapLocation = sender.location(in: sceneView)
        // Does location match location of horizontal plane?
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        guard !hitTest.isEmpty else {
            return
        }
        addIkeaItem(hitTestResult: hitTest.first!)
    }

    @objc func handlePinchGesture(sender: UIPinchGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {
            return
        }
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        guard !hitTest.isEmpty else {
            return
        }
        let results = hitTest.first!
        let node = results.node
        // sender.scale at which user is pinching node
        let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
        node.runAction(pinchAction)
        sender.scale = 1.0
    }

    func addIkeaItem(hitTestResult: ARHitTestResult) {
        guard let selectedIkeaItem = selectedIkeaItem else {
            return
        }
        let scene = SCNScene(named: "art.scnassets/\(selectedIkeaItem).scn")
        guard let node = scene?.rootNode.childNode(withName: selectedIkeaItem, recursively: false) else {
            return
        }
        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        if selectedIkeaItem == "table" {
            centerPivot(for: node)
        }
        node.name = "ikea-item"
        rootNodeChildrenNames.append("ikea-item")
        sceneView.scene.rootNode.addChildNode(node)
    }

    func handlePlaneDidAdd(node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.topLabel.isHidden = false
            self?.topLabel.text = "Plane detected"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
                self?.topLabel.isHidden = true
            })
        }
    }

    @objc func rotateNode(sender: UILongPressGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {
            return
        }
        let holdLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(holdLocation)
        guard !hitTest.isEmpty else {
            return
        }
        let results = hitTest.first!
        let node = results.node
        if sender.state == .began {
            let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
            let foreverAction = SCNAction.repeatForever(action)
            node.runAction(foreverAction)
        } else if sender.state == .ended {
            node.removeAllActions()
        }
    }

}

// MARK: - Section 9 - Vehicle

private extension ViewController {

    func addCar() {
        guard let pointOfView = sceneView.pointOfView else {
            return
        }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, -transform.m43)
        let positionInFrontOfCamera = orientation + location

        guard
            let scene = SCNScene(named: "car-scene.scn"),
            let carChassisNode = scene.rootNode.childNode(withName: "chassis", recursively: false),
            let rearRightWheel = carChassisNode.childNode(withName: "rearRightParent", recursively: false),
            let rearLeftWheel = carChassisNode.childNode(withName: "rearLeftParent", recursively: false),
            let frontRightWheel = carChassisNode.childNode(withName: "frontRightParent", recursively: false),
            let frontLeftWheel = carChassisNode.childNode(withName: "frontLeftParent", recursively: false)
        else {
            fatalError("something was nil")
        }

        carChassisNode.position = positionInFrontOfCamera
        // make car fall
        let body = SCNPhysicsBody(
            type: .dynamic, // we want it to be affected by forces
            shape: SCNPhysicsShape(
                node: carChassisNode,
                options: [SCNPhysicsShape.Option.keepAsCompound: true])) // true for when we have more shapes
        // Make car slower
        body.mass = 1 // Newtons, it is heavier
        carChassisNode.physicsBody = body
        vehicle = SCNPhysicsVehicle(
            chassisBody: carChassisNode.physicsBody!,
            wheels: [
                SCNPhysicsVehicleWheel(node: rearRightWheel),
                SCNPhysicsVehicleWheel(node: rearLeftWheel),
                SCNPhysicsVehicleWheel(node: frontRightWheel),
                SCNPhysicsVehicleWheel(node: frontLeftWheel)])

        carChassisNode.name = "vehicle"
        rootNodeChildrenNames.append("vehicle")

        sceneView.scene.physicsWorld.addBehavior(vehicle)
        sceneView.scene.rootNode.addChildNode(carChassisNode)
    }

    func makeConcreteNode(for anchor: ARAnchor) -> SCNNode? {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return nil
        }
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        setDiffuse(#imageLiteral(resourceName: "9_Car/concrete"), to: concreteNode)
        // Make sure one can see the lava from both sides
        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
        concreteNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        concreteNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        // Give concrete a physics body
        let staticBody = SCNPhysicsBody.static() // static is anything that's gonna be fixed in one place. It needs to support other bodies. Gravity won't affect it
        concreteNode.physicsBody = staticBody
        return concreteNode
    }

    func setUpAccelerometer() {
        guard .section9 == currentSection else {
            return
        }
        guard motionManager.isAccelerometerAvailable else {
            print ("Accelerometer not available")
            return
        }
        motionManager.accelerometerUpdateInterval = 1/60 // 60 times a second
        motionManager.startAccelerometerUpdates(to: .main, withHandler: { [weak self] (accelerometerData, error) in
            guard let self = self else {
                return
            }
            guard error == nil else {
                print (error!.localizedDescription)
                return
            }
            guard let accelerometerData = accelerometerData else {
                return
            }
            self.accelerometerDidChange(acceleration: accelerometerData.acceleration)
        })
    }

    func accelerometerDidChange(acceleration: CMAcceleration) {
        // The phone has an "inner" Cartesian coordinate system
        // Moving it to the right makes the x gravity possitive, moving it to the left, negative.

        // Make a smoother steering angle by eliminating non gravitational accelerations (movements, for example)
        accelerationValues[1] = filterNonGravitationalAcceleration(from: accelerationValues[1], updatedAcceleration: acceleration.y)
        accelerationValues[0] = filterNonGravitationalAcceleration(from: accelerationValues[0], updatedAcceleration: acceleration.x)

        // Whatever is the y value represents the current orientation of the phone.
        if accelerationValues[0] > 0 { // This is > 0 when phone is oriented to he right
            self.orientation = -CGFloat(accelerationValues[1])
        } else { // This is > 0 when phone is oriented to he left
            self.orientation = CGFloat(accelerationValues[1])
        }
        // Without using filtered values
//        if acceleration.x > 0 {
//            self.orientation = -CGFloat(acceleration.y)
//        } else {
//            self.orientation = CGFloat(acceleration.y)
//        }
    }

    func filterNonGravitationalAcceleration(from currentAcceleration: Double, updatedAcceleration: Double) -> Double {
        let filteringFactor = 0.5
        return updatedAcceleration * filteringFactor + currentAcceleration * (1 - filteringFactor)
        
    }

    func handleDidSimulatePhysics() {
        guard .section9 == currentSection else {
            return
        }
        var engineForce: CGFloat = 0
        var breakingForce: CGFloat = 0
        // The orientation is negative because the car is rotated 180 degrees horizontally so it does not face us.
        vehicle.setSteeringAngle(-orientation, forWheelAt: 2)
        vehicle.setSteeringAngle(-orientation, forWheelAt: 3)
        if userTouches == 1 {
            engineForce = 5
        } else if userTouches == 2 {
            engineForce = -5
        } else if userTouches == 3 {
            breakingForce = 100
        } else {
            engineForce = 0
        }

        // Notice how force is applied from the back.
        vehicle.applyEngineForce(engineForce, forWheelAt: 0)
        vehicle.applyEngineForce(engineForce, forWheelAt: 1)

        // Breaking logic
        vehicle.applyBrakingForce(breakingForce, forWheelAt: 0)
        vehicle.applyBrakingForce(breakingForce, forWheelAt: 1)
    }

}

// MARK: - Section 10 - Measurement

private extension ViewController {

    @objc func handleMeasurementTap(_ sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {
            return
        }
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        guard startingPosition == nil else {
            startingPosition?.removeFromParentNode()
            startingPosition = nil
            return
        }
        let camera = currentFrame.camera
        // This encondes position of camera. The third column is what we care about
        let cameraTransform = camera.transform
        
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.005))
        setDiffuse(.systemPink, to: sphereNode)

        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1
        let modifiedMatrix = simd_mul(cameraTransform, translationMatrix)

        sphereNode.name = "distance"
        rootNodeChildrenNames.append("distance")
        // Let's put the phone 0.1 meters away from where I am
        sphereNode.simdTransform = modifiedMatrix
        sceneView.scene.rootNode.addChildNode(sphereNode)
        startingPosition = sphereNode
    }

    func handleUpdateAtTime() {
        guard .section10 == currentSection else {
            return
        }
        guard let startingPosition = self.startingPosition else {
            return
        }
        // current position of camera's point of view
        // has current orientation and location of camera view
        guard let pointOfView = sceneView.pointOfView else {
            return
        }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let xDistanceValue = location.x - startingPosition.position.x
        let yDistanceValue = location.y - startingPosition.position.y
        let zDistanceValue = location.z - startingPosition.position.z

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.xDistanceLabel.text = String(format: "%.2f", xDistanceValue) + "m"
            self.yDistanceLabel.text = String(format: "%.2f", yDistanceValue) + "m"
            self.zDistanceLabel.text = String(format: "%.2f", zDistanceValue) + "m"
            let diagonalDistanceValue = self.calculateDistance(x: xDistanceValue, y: yDistanceValue, z: zDistanceValue)
            self.diagonalDistanceLabel.text = String(format: "%.2f", diagonalDistanceValue) + "m"
        }
    }

}

// MARK: - Section 11 - AR Portal

private extension ViewController {

    @objc func handlePortalTap(_ sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {
            return
        }
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if let firstHitTestResult = hitTestResult.first {
            // we're going to add our room
            addPortal(hitTestResult: firstHitTestResult)
        } else {
            
        }
    }

    func addPortal(hitTestResult: ARHitTestResult) {
        guard
            let portalScene = SCNScene(named: "art.scnassets/portal.scn"),
            let portalNode = portalScene.rootNode.childNode(withName: "portal", recursively: false)
        else {
            fatalError("Either portalScene or portalNode do not exist")
        }

        // This encodes position of plane
        let transform = hitTestResult.worldTransform
        let planeXPosition = transform.columns.3.x
        let planeYPosition = transform.columns.3.y
        let planeZPosition = transform.columns.3.z - 1
        portalNode.position = SCNVector3(planeXPosition, planeYPosition, planeZPosition)
        portalNode.name = "portal"
        rootNodeChildrenNames.append("portal")
        sceneView.scene.rootNode.addChildNode(portalNode)
        addPortalPlane(nodeName: "roof", portalNode: portalNode, imageName: "top")
        addPortalPlane(nodeName: "floor", portalNode: portalNode, imageName: "bottom")
        addWallPlane(nodeName: "backWall", portalNode: portalNode, imageName: "back")
        addWallPlane(nodeName: "sideDoorB", portalNode: portalNode, imageName: "sideDoorB")
        addWallPlane(nodeName: "sideDoorA", portalNode: portalNode, imageName: "sideDoorA")
        addWallPlane(nodeName: "sideWallB", portalNode: portalNode, imageName: "sideB")
        addWallPlane(nodeName: "sideWallA", portalNode: portalNode, imageName: "sideA")
    }

    func addWallPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        guard let childNode = portalNode.childNode(withName: nodeName, recursively: true) else {
            fatalError("Node \(nodeName) does not exist")
        }
        guard let assetImage = UIImage(named: "11_Portal/\(imageName)") else {
            fatalError("Image 11_Portal/\(imageName) does not exist")
        }
        setDiffuse(assetImage, to: childNode)
        // We render the wall after the mask, which is translucent.
        // That way the colors are mixed. Since mask is very translucent, the walls will be almost invisible
        childNode.renderingOrder = 200
        guard let maskNode = childNode.childNode(withName: "mask", recursively: false) else {
            fatalError("mask does not exist")
        }
        setTransparency(0.000001, to: maskNode)
        
    }

    func addPortalPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        guard let childNode = portalNode.childNode(withName: nodeName, recursively: true) else {
            fatalError("Node \(nodeName) does not exist")
        }
        guard let assetImage = UIImage(named: "11_Portal/\(imageName)") else {
            fatalError("Image 11_Portal/\(imageName) does not exist")
        }
        setDiffuse(assetImage, to: childNode)
        // by rendering later, we manage these to be sort of transparent
        childNode.renderingOrder = 200
    }

}

// MARK: - Helpers

private extension ViewController {

    func setDiffuse(_ color: UIColor, to node: SCNNode) {
        node.geometry?.firstMaterial?.diffuse.contents = color
    }

    func setSpecular(_ color: UIColor, to node: SCNNode) {
        node.geometry?.firstMaterial?.specular.contents = color
    }

    func setDiffuse(_ image: UIImage?, to node: SCNNode) {
        node.geometry?.firstMaterial?.diffuse.contents = image
    }

    func setTransparency(_ opacity: CGFloat, to node: SCNNode) {
        node.geometry?.firstMaterial?.transparency = opacity
    }

    func setSpecular(_ image: UIImage?, to node: SCNNode) {
        node.geometry?.firstMaterial?.specular.contents = image
    }

    func setEmission(_ image: UIImage?, to node: SCNNode) {
        node.geometry?.firstMaterial?.emission.contents = image
    }

    func setNormal(_ image: UIImage?, to node: SCNNode) {
        node.geometry?.firstMaterial?.normal.contents = image
    }

    func makeForeverRotation(z: CGFloat = 0, duration: TimeInterval) -> SCNAction {
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: z, duration: duration)
        let foreverRotation = SCNAction.repeatForever(rotation)
        return foreverRotation
    }

    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2)
    }

    func makeRandomNumber(_ first: CGFloat, _ second: CGFloat) -> CGFloat {
        CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(first - second) + min(first, second)
    }

    func makeRandomVector() -> SCNVector3 {
        return SCNVector3(
            makeRandomNumber(-1, 1),
            makeRandomNumber(-0.5, 0.5),
            makeRandomNumber(-1, 1))
    }

    func calculateDistance(x: Float, y: Float, z: Float) -> Float {
        sqrtf(x * x + y * y + z * z)
    }

}

extension Int {

    var degreesToRadians: Double {
        Double(self) * .pi/180
    }
}

extension Double {

    var degreesToRadians: Double {
        self * .pi/180
    }
}


func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {

    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)

}

extension ARPlaneAnchor {

    var position: SCNVector3 {
        return SCNVector3(
            center.x,
            center.y,
            center.z)
    }

}
