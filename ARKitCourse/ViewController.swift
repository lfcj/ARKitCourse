import UIKit
import ARKit

class ViewController: UIViewController {

    // MARK: - Nested Types

    enum Section {
        // Fundamentals + makeHouse
        case section3
        // Draw app
        case section4
        // Solar system
        case section5
        // Jellyfish
        case section6
    }

    // MARK: - Outlets

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!

    // MARK: - Properties

    private let currentSection = Section.section6
    private let configuration = ARWorldTrackingConfiguration()
    private let jellyFishNodeName = "Jellyfish"
    private var countdown = 10
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.session.run(configuration)

        configureCurrentSection()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeSolarSystem()
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
        default:
            break
        }
    }

    @IBAction func didTapMiddleButton(_ sender: Any) {
    }

    @IBAction func didTapRightButton(_ sender: Any) {
        switch currentSection {
        case .section3:
            restartSession()
        case .section6:
            timer?.invalidate()
            timer = nil
            resetJellyfishLabel()
            restartSession(nodeName: jellyFishNodeName)
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

        switch currentSection {
        case .section3:
            configureSection3(isHidden: false)
        case .section4:
            configureSection4(isHidden: false)
        case .section5:
            configureSection5(isHidden: false)
        case .section6:
            configureSection6(isHidden: false)
        }
    }

    func configureSection3(isHidden: Bool) {
        middleButton.isHidden = !isHidden
        [leftButton, rightButton].forEach { $0?.isHidden = isHidden }
        sceneView.autoenablesDefaultLighting = !isHidden
    }

    func configureSection4(isHidden: Bool) {
        [leftButton, rightButton].forEach { $0?.isHidden = !isHidden }
        middleButton.isHidden = isHidden
        self.sceneView.showsStatistics = !isHidden
        self.sceneView.delegate = self
    }

    func configureSection5(isHidden: Bool) {
        sceneView.autoenablesDefaultLighting = !isHidden
        [leftButton, rightButton, middleButton].forEach { $0?.isHidden = !isHidden}
    }
    func configureSection6(isHidden: Bool) {
        middleButton.isHidden = !isHidden
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
        leftButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        rightButton.setImage(#imageLiteral(resourceName: "Reset"), for: .normal)
        resetJellyfishLabel()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleJellyfishTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
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

        sceneView.scene.rootNode.addChildNode(node)
        node.addChildNode(boxNode)
        boxNode.addChildNode(doorNode)
    }

    func restartSession(nodeName: String? = nil) {
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if nodeName == nil || nodeName == node.name {
                node.removeFromParentNode()
            }
        }
        sceneView.session.pause()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

}

// MARK: - ARSCNViewDelegate + Section 4 - Drawing

extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard .section4 == currentSection else {
            return
        }
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
                self?.sceneView.scene.rootNode.addChildNode(sphereNode)
                self?.setDiffuse(.red, to: sphereNode)
            }
            else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
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

        sceneView.scene.rootNode.addChildNode(sun)
        sceneView.scene.rootNode.addChildNode(earth)
        sceneView.scene.rootNode.addChildNode(venus)
    }

    func makeEarth() -> SCNNode {
        let earthParent = SCNNode()
        let earth = makePlanet(
            geometry: SCNSphere(radius: 0.2),
            diffuse: #imageLiteral(resourceName: "Earth day"),
            specular: #imageLiteral(resourceName: "Earth Specular"),
            emission: #imageLiteral(resourceName: "Earth Emission"),
            normal: #imageLiteral(resourceName: "Earth Normal"),
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
            diffuse: #imageLiteral(resourceName: "moon Diffuse"),
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
        setDiffuse(#imageLiteral(resourceName: "Sun diffuse"), to: sun)
        sun.position = SCNVector3(0,0,-2)
        sun.runAction(makeForeverRotation(duration: 8))
        return sun
    }

    func makeVenus() -> SCNNode {
        let venusParent = SCNNode()
        let venus = makePlanet(
            geometry: SCNSphere(radius: 0.1),
            diffuse: #imageLiteral(resourceName: "Venus Surface"),
            specular: nil,
            emission: #imageLiteral(resourceName: "Venus Atmosphere"),
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
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyfishNode = jellyFishScene?.rootNode.childNode(withName: jellyFishNodeName, recursively: false)
        jellyfishNode?.position = makeRandomVector()
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

            SCNTransaction.begin()
            self.animateNode(node: node)
            SCNTransaction.completionBlock = { [weak self] in
                node.removeFromParentNode()
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

    func makeRandomNumber(_ first: CGFloat, _ second: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(first - second) + min(first, second)
    }

    func makeRandomVector() -> SCNVector3 {
        return SCNVector3(
            makeRandomNumber(-1, 1),
            makeRandomNumber(-0.5, 0.5),
            makeRandomNumber(-1, 1))
    }

}

extension Int {

    var degreesToRadians: Double {
        Double(self) * .pi/180
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {

    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)

}
