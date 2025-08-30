import SwiftUI
import simd

struct TiltFlipCard<Front: View, Back: View>: View {
    var front: (_ normal: SIMD3<Float>) -> Front
    var back: (_ normal: SIMD3<Float>) -> Back

    @State private var tiltX: CGFloat = 0
    @State private var tiltY: CGFloat = 0
    @State private var isFlipped = false
    @GestureState private var drag = CGSize.zero

    private let responsiveness: CGFloat = 0.15
    private let tiltMax: CGFloat = 10

    var body: some View {
        let worldNormal = normalFromTilt(tiltXDeg: Float(tiltX), tiltYDeg: Float(tiltY))
        let frontNormal = worldNormal
        let backNormal = -worldNormal

        ZStack {
            ZStack {
                front(frontNormal)
                    .opacity(isFlipped ? 0 : 1)
                back(backNormal)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(isFlipped ? 1 : 0)
            }
            .compositingGroup()
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
            .onTapGesture {
                withAnimation(.spring) {
                    isFlipped.toggle()
                }
            }
        }
        .rotation3DEffect(.degrees(tiltX), axis: (x: 1, y: 0, z: 0))
        .rotation3DEffect(.degrees(tiltY), axis: (x: 0, y: 1, z: 0))
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($drag) { value, state, _ in
                    state = value.translation
                }
                .onEnded { _ in
                    withAnimation(.spring) {
                        tiltX = 0
                        tiltY = 0
                    }
                }
        )
        .onAppear {
            withAnimation {
                tiltY = 5
            } completion: {
                tiltY = 0
            }
        }
        .onChange(of: drag, initial: false) { _, newValue in
            tiltX = clampFloat(-newValue.height * responsiveness, -tiltMax, tiltMax)
            tiltY = clampFloat(newValue.width * responsiveness, -tiltMax, tiltMax)
        }
    }

    private func normalFromTilt(tiltXDeg: Float, tiltYDeg: Float) -> SIMD3<Float> {
        let n0 = SIMD3<Float>(0, 0, 1)

        let rx = rotationMatrix(axis: SIMD3<Float>(1, 0, 0), degrees: tiltXDeg)
        let ry = rotationMatrix(axis: SIMD3<Float>(0, 1, 0), degrees: tiltYDeg)

        let r = simd_mul(ry, rx)

        let v = simd_mul(r, SIMD4<Float>(n0, 0)).xyz
        return simd_normalize(v)
    }

    private func rotationMatrix(axis: SIMD3<Float>, degrees: Float) -> simd_float4x4 {
        let rad = degrees * .pi / 180
        let a = simd_normalize(axis)
        let c = cos(rad)
        let s = sin(rad)
        let t = 1 - c

        let m = simd_float3x3(
            SIMD3<Float>(t * a.x * a.x + c, t * a.x * a.y - s * a.z, t * a.x * a.z + s * a.y),
            SIMD3<Float>(t * a.x * a.y + s * a.z, t * a.y * a.y + c, t * a.y * a.z - s * a.x),
            SIMD3<Float>(t * a.x * a.z - s * a.y, t * a.y * a.z + s * a.x, t * a.z * a.z + c)
        )

        return simd_float4x4(
            SIMD4<Float>(m.columns.0, 0),
            SIMD4<Float>(m.columns.1, 0),
            SIMD4<Float>(m.columns.2, 0),
            SIMD4<Float>(0, 0, 0, 1))
    }

    private func clampFloat(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        min(max(v, lo), hi)
    }
}

extension SIMD4 where Scalar == Float {
    fileprivate var xyz: SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}
