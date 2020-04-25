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

    let configuration = ARWorldTrackingConfiguration()

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!

    private var currentSection = Section.section3

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.session.run(configuration)

        configureCurrentSection()
    }

    // MARK: - Actions

    @IBAction func didTapLeftButton(_ sender: Any) {
        switch currentSection {
        case .section3:
            makeHouse()
        default: break
        }
    }

    @IBAction func didTapMiddleButton(_ sender: Any) {
    }

    @IBAction func didTapRightButton(_ sender: Any) {
        switch currentSection {
        case .section3:
            restartSession()
        default: break
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
            break
        case .section5:
            break
        case .section6:
            break
        }
    }

    func configureSection3(isHidden: Bool) {
        middleButton.isHidden = true
        [leftButton, rightButton].forEach { $0?.isHidden = isHidden }
        guard !isHidden else {
            return
        }
        sceneView.autoenablesDefaultLighting = true
    }
    func configureSection4(isHidden: Bool) {
        
    }
    func configureSection5(isHidden: Bool) {
        
    }
    func configureSection6(isHidden: Bool) {
        
    }
}

// MARK: - Section 3

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

    func restartSession() {
        sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

}

// MARK: - Helpers

extension ViewController {

    func setDiffuse(_ color: UIColor, to node: SCNNode) {
        node.geometry?.firstMaterial?.diffuse.contents = color
    }

    func setSpecular(_ color: UIColor, to node: SCNNode) {
        node.geometry?.firstMaterial?.specular.contents = color
    }

    func randomNumber(_ first: CGFloat, _ second: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(first - second) + min(first, second)
    }

}

extension Int {

    var degreesToRadians: Double {
        Double(self) * .pi/180
    }
}

