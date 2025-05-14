import Foundation

public enum QuantizationLevel: String {
    case fp16, int8, q5_1, q4_k, q4_0, q2_k

    public func factor() -> Double {
        switch self {
            case .fp16: return 1.0
            case .int8: return 0.8
            case .q5_1: return 0.7
            case .q4_k: return 0.6
            case .q4_0: return 0.5
            case .q2_k: return 0.4
        }
    }
}

public struct LargeLanguageModel {
    public let name: String
    public let parameters: Int              // in billions
    public let quantization: QuantizationLevel
    public let diskSizeGB: Double           // size of the GGUF or model file
    public let requiresRAMGB: Double        // approx needed RAM to run

    public init(
        name: String,
        parameters: Int,
        quantization: QuantizationLevel,
        diskSizeGB: Double,
        requiresRAMGB: Double
    ) {
        self.name = name 
        self.parameters = parameters 
        self.quantization = quantization
        self.diskSizeGB = diskSizeGB
        self.requiresRAMGB = requiresRAMGB
    }

    public func estimateTokensPerSecond(on machine: MachineSpecification) -> Double? {
        guard machine.ramGB >= self.requiresRAMGB else {
            print("Model does not fit in memory.")
            return nil
        }

        let quantizationFactor: Double = self.quantization.factor()

        let baseTokenRate = 3.0  // tokens/sec per core on decent ARM CPU

        var rate = baseTokenRate * Double(machine.cpuCores) * quantizationFactor

        if machine.hasMetalAcceleration {
            rate *= 1.2
        }

        let penalty = log(Double(self.parameters)) / log(2.0)
        rate /= penalty

        return round(rate * 10) / 10 // round to 1 decimal place
    }
}

public struct MachineSpecification {
    public let cpuCores: Int
    public let ramGB: Double
    public let hasMetalAcceleration: Bool
    public let memoryBandwidthGBps: Double
    
    public init(
        cpuCores: Int,
        ramGB: Double,
        hasMetalAcceleration: Bool,
        memoryBandwidthGBps: Double
    ) {
        self.cpuCores = cpuCores
        self.ramGB = ramGB
        self.hasMetalAcceleration = hasMetalAcceleration
        self.memoryBandwidthGBps = memoryBandwidthGBps
    }
}


