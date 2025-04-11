import java.util.Scanner;

// Sources:


public class CarbonEmissionCalculator {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("\nWelcome to the Carbon Emission Calculator!");
        System.out.println("This tool estimates the CO2 emissions based on your travel details.\n");

        System.out.print("Enter travel mode (car, bus, train, plane, bike, motorcycle): ");
        String mode = scanner.nextLine().trim().toLowerCase();

        if (!isValidMode(mode)) {
            System.out.println("Invalid travel mode. Please enter one of the following: car, bus, train, plane, bike, motorcycle.");
            scanner.close();
            return;
        }

        System.out.print("Enter distance traveled in kilometers: ");
        while (!scanner.hasNextDouble()) {
            System.out.println("Invalid input. Please enter a number.");
            scanner.next();
        }
        double distance = scanner.nextDouble();
        scanner.nextLine(); // consume leftover newline

        if (distance < 0) {
            System.out.println("Distance must be a positive value.");
            scanner.close();
            return;
        }

        double emissionFactor;

        if (mode.equals("car")) {
            System.out.print("Enter fuel type (petrol, diesel, electric): ");
            String fuel = scanner.nextLine().trim().toLowerCase();
            emissionFactor = getCarEmissionFactor(fuel);
            if (emissionFactor == -1) {
                System.out.println("Invalid fuel type.");
                scanner.close();
                return;
            }
        } else if (mode.equals("plane")) {
            System.out.print("Enter cabin class (economy, business, first): ");
            String cabin = scanner.nextLine().trim().toLowerCase();
            System.out.print("Is this a round trip? (yes/no): ");
            String roundTripInput = scanner.nextLine().trim().toLowerCase();
            boolean isRoundTrip = roundTripInput.equals("yes");
            emissionFactor = getPlaneEmissionFactor(cabin);
            if (emissionFactor == -1) {
                System.out.println("Invalid cabin class.");
                scanner.close();
                return;
            }
            if (isRoundTrip) {
                distance *= 2;
            }
        } else {
            emissionFactor = getGeneralEmissionFactor(mode);
        }

        double emissions = distance * emissionFactor;

        System.out.printf("\nEstimated carbon emissions for traveling %.2f km by %s: %.2f kg CO2%n", distance, mode, emissions);
        System.out.println("\nNote: Emission factors are approximations and may vary based on vehicle type, fuel efficiency, and other variables.");

        scanner.close();
    }

    private static boolean isValidMode(String mode) {
        return mode.equals("car") || mode.equals("bus") || mode.equals("train") || mode.equals("plane") || mode.equals("bike") || mode.equals("motorcycle");
    }

    private static double getCarEmissionFactor(String fuel) {
        switch (fuel) {
            case "petrol": return 0.12;
            case "diesel": return 0.15;
            case "electric": return 0.05;
            default: return -1;
        }
    }

    private static double getPlaneEmissionFactor(String cabinClass) {
        switch (cabinClass) {
            case "economy": return 0.15;
            case "business": return 0.30;
            case "first": return 0.40;
            default: return -1;
        }
    }

    private static double getGeneralEmissionFactor(String mode) {
        switch (mode) {
            case "bus": return 0.08;
            case "train": return 0.04;
            case "motorcycle": return 0.10;
            case "bike": return 0.00; // human-powered
            default: return -1;
        }
    }
}