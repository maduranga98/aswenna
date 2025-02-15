import 'package:aswenna/data/constants/list_data.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Map<String, String> districtToDSOConnector(
  AppLocalizations localizations,
  String district,
) {
  switch (district) {
    case 'ampara':
      return amparaSet(localizations);
    case 'anuradhapura':
      return anuradhapuraSet(localizations);
    case 'batticaloa':
      return batticaloaSet(localizations);
    case 'badulla':
      return badullaSet(localizations);
    case 'colombo':
      return colomboSet(localizations);
    case 'galle':
      return galleSet(localizations);
    case 'gampaha':
      return gampahaSet(localizations);
    case 'hambantota':
      return hambantotaSet(localizations);
    case 'jaffna':
      return jaffnaSet(localizations);
    case 'kalutara':
      return kalutaraSet(localizations);
    case 'kandy':
      return kandySet(localizations);
    case 'kegalle':
      return kegalleSet(localizations);
    case 'kilinochchi':
      return kilinochchiSet(localizations);
    case 'kurunegala':
      return kurunegalaSet(localizations);
    case 'mannar':
      return mannarSet(localizations);
    case 'matale':
      return mataleSet(localizations);
    case 'matara':
      return mataraSet(localizations);
    case 'monaragala':
      return moneragalaSet(localizations);
    case 'mullaitivu':
      return mullaitivuSet(localizations);
    case 'nuwaraEliya':
      return nuwaraEliyaSet(localizations);
    case 'polonnaruwa':
      return polonnaruwaSet(localizations);
    case 'puttalam':
      return puttalamSet(localizations);
    case 'ratnapura':
      return ratnapuraSet(localizations);
    case 'trincomalee':
      return trincomaleeSet(localizations);
    default:
      return vavuniyaSet(localizations);
  }
}

// paddy connector
List<String> getPaddyTpeFromCode(String code) {
  switch (code) {
    case 'BG':
      return bg;
    case 'BW':
      return bw;
    case 'LD':
      return ld;
    default:
      return at;
  }
}

//main grid to first step list connector
List<String> mainGridConnector(String keyword, String lan) {
  if (lan == 'si') {
    switch (keyword) {
      case 'harvest':
        return harvestSin;
      case 'lands':
        return landsSin;
      case 'seedsPants&materials':
        return plantingMaterialOrSeedsCommonSin;
      case 'labour':
        return labourSin;
      case 'transport':
        return transportationSin;
      case 'machineries':
        return machineriesSin;
      case 'agroequip':
        return agroEqupimentsSin;
      case 'agroChems':
        return chemsSin;
      case 'advice':
        return adviceSin;
      case 'info':
        return infoSin;
      case 'animals':
        return animalsSin;
      case 'fertilizer':
        return fertilizerSin;
      case 'import':
        return importListSin;
      case 'export':
        return exportListSin;
      case 'chemfertilizer':
        return fertilizerChemSin;
      case 'production':
        return productionSin;
      case 'vehicles':
        return vehicleSin;
      default:
        return [];
    }
  } else {
    switch (keyword) {
      case 'harvest':
        return harvestEN;
      case 'lands':
        return landsEn;
      case 'seedsPants&materials':
        return plantingMaterialOrSeedsCommonEn;
      case 'labour':
        return labourEn;
      case 'transport':
        return transportationEn;
      case 'machineries':
        return machineriesEn;
      case 'agroequip':
        return agroEqupimentsEN;
      case 'agroChems':
        return chemsEn;
      case 'advice':
        return adviceEn;
      case 'info':
        return infoEn;
      case 'animals':
        return animalsEn;
      case 'fertilizer':
        return fertilizerEn;
      case 'import':
        return importListEn;
      case 'export':
        return exportListEn;
      case 'chemfertilizer':
        return fertilizerChemEn;
      case 'production':
        return productionEn;
      case 'vehicles':
        return vehicleEn;
      default:
        return [];
    }
  }
}

// first list step to sub grids

List<String> subGridConnector(String keyword, String lan) {
  if (lan == 'si') {
    switch (keyword) {
      case 'quadrupeds':
        return fourLegsSin;
      case 'bipeds':
        return depaSin;
      case 'fish':
        return fishSin;
      case 'honeyBee':
        return honeyBeeSin;
      case 'paddy':
        return paddySin;
      case 'cerealCrops':
        return cerealCropsSin;
      case 'coconut':
        return coconutSin;
      case 'vegetables':
        return vegetablesSin;
      case 'fruits':
        return fruitsSin;
      case 'potato':
        return potatoSin;
      case 'greenleaves':
        return greenLeavesSin;
      case 'flowers':
        return flowersSin;
      case 'cashew':
        return cashewSin;
      case 'forestry':
        return forestrySin;
      case 'mudlands':
        return landsCommonSin;
      case 'lands':
        return landsCommonSin;
      case 'buffalo':
        return buffaloSin;
      case 'cattle':
        return cattleSin;
      case 'goat':
        return goatSin;
      case 'pig':
        return pigSin;
      case 'rabbit':
        return rabbitSin;
      case 'sheep':
        return sheepeSin;
      case 'local':
        return localPaddySin;
      case 'governmentNotices':
        return governmentNoticesSin;
      case 'prices':
        return pricesSin;
      case 'importTypes':
        return importSin;
      case 'countryShipments':
        return exportTypesSin;
      case 'solidfertilizer':
        return solidFerlizerSin;
      case 'landPreparationEquipment':
        return landPreparationEquSin;
      case 'cultivationEquipment':
        return cultivationEquSin;
      case 'fertilizerApplicationEquipment':
        return fertilizerAppEquSin;
      case 'weedingEquipment':
        return weedingEquSin;
      case 'waterApplicationEquipment':
        return waterAppEquSin;
      case 'harvestingEquipment':
        return harvestingpEquSin;
      case 'coveringEquipment':
        return coveringEquSin;
      case 'safetyEquipment':
        return safetyEquSin;
      case 'Drivers':
        return labourCommonSin;
      case 'wellsandTubeWells':
        return labourCommonSin;
      case 'fixingCoveringEquipment':
        return labourCommonSin;
      case 'installationofSafetyEquipment':
        return labourCommonSin;
      case 'landpreparationworks':
        return labourCommonSin;
      case 'cultivation':
        return labourCommonSin;
      case 'fertilizing':
        return labourCommonSin;
      case 'applicationofAgrochemicals':
        return labourCommonSin;
      case 'weedcontrol':
        return labourCommonSin;
      case 'applyingwater':
        return labourCommonSin;
      case 'harvesting':
        return labourCommonSin;
      case 'laterHarvesting':
        return labourCommonSin;
      case 'postQuestionProcessing':
        return labourCommonSin;
      case 'preparationofbyproducts':
        return labourCommonSin;
      case 'animalHusbandry':
        return labourCommonSin;
      case 'farmManagement':
        return labourCommonSin;
      case 'chickens':
        return chickenSin;
      case 'Turkey':
        return birdsComonSin;
      case 'duck':
        return birdsComonSin;
      case 'vatu':
        return birdsComonSin;
      case 'pigeon':
        return birdsComonSin;
      case 'loveBirds':
        return birdsComonSin;
      case 'gumkukulu':
        return birdsComonSin;
      case 'broilers':
        return broilersSin;
      case 'layers':
        return layersSin;
      case 'cockres':
        return cockresSin;
      case 'parents':
        return birdsComonSin;
      case 'calf':
        return birdsComonSin;
      case 'meat':
        return birdsComonSin;
      case 'medicine':
        return birdsComonSin;
      case 'gear':
        return birdsComonSin;
      case 'freshWater':
        return freshWaterSin;
      case 'saltWater':
        return seaWaterSin;
      case 'ornemantalFish':
        return fancySin;
      case 'singlefertilizer':
        return singlefertilizerSin;
      case 'pipes':
        return pipesSin;
      case 'eire':
        return cowsComonSin;
      case 'fecian':
        return cowsComonSin;
      case 'jagasi':
        return cowsComonSin;
      case 'glee':
        return cowsComonSin;
      case 'lanka':
        return cowsComonSin;
      case 'sindhi':
        return cowsComonSin;
      case 'amz':
        return cowsComonSin;
      case 'afs':
        return cowsComonSin;
      case 'mura':
        return cowsComonSin;
      case 'nilirawi':
        return cowsComonSin;
      case 'surti':
        return cowsComonSin;
      case 'jamnapari':
        return cowsComonSin;
      case 'satan':
        return cowsComonSin;
      case 'boyer':
        return cowsComonSin;
      case 'kottukavadi':
        return cowsComonSin;
      case 'landiers':
        return fourlegsComonSin;
      case 'largewhite':
        return fourlegsComonSin;
      case 'duro':
        return fourlegsComonSin;
      case 'newzealandwhite':
        return fourlegsComonSin;
      case 'redmadras':
        return fourlegsComonSin;
      case 'seeds':
        return plantingMaterialOrSeedsSin;
      case 'plants':
        return plantingMaterialOrSeedsSin;
      case 'plantingParts':
        return plantingMaterialOrSeedsSin;
      case 'bonsai':
        return plantingMaterialOrSeedsSin;
      case 'import':
        return plantingMaterialOrSeedsCommonSin;
      case 'export':
        return plantingMaterialOrSeedsCommonSin;
      case 'smallanimals':
        return exportSubsSin;
      case 'importedgear':
        return exportSubsSin;
      case 'cattlecalf':
        return cattleTypeSin;
      case 'growncattle':
        return cattleTypeSin;
      case 'buffalocalf':
        return buffaloTypeSin;
      case 'grownbuffalo':
        return buffaloTypeSin;
      case 'goatcalf':
        return goatTypeSin;
      case 'growngoat':
        return goatTypeSin;
      case 'sheepcalf':
        return sheepeTypeSin;
      case 'grownsheep':
        return sheepeTypeSin;
      case 'pigcalf':
        return pigTypeSin;
      case 'grownpig':
        return pigTypeSin;
      case 'rabbitcalf':
        return rabbitTypeSin;
      case 'grownrabbit':
        return rabbitTypeSin;
      case 'agriculturalequipementsandmachinery':
        return agriEqupimentandmachineriesSin;
      case 'paddyrelatedproducts':
        return paddyrelatedproductsSin;
      case 'coconutrelatedproducts':
        return coconutrelatedproductsSin;
      case 'flowersrelatedproducts':
        return flowersrelatedproductsSin;
      case 'forestryrelatedproducts':
        return forestryrelatedproductsSin;
      case 'othercerealcropsrelatedproducts':
        return cerealCropsSin;
      // case 'seeds':
      //   return seedsListSin;
      // case 'plants':
      //   return palntListSin;
      // case 'plantingmaterial':
      //   return plantingmaterialListSin;
      case 'Tilapia':
        return fishComonSin;
      case 'Catla':
        return fishComonSin;
      case 'Rohu':
        return fishComonSin;
      case 'Mirihal':
        return fishComonSin;
      case 'freshwaterShrimp':
        return fishComonSin;
      case 'Prawns':
        return fishComonSin;
      case 'Guppy':
        return fishComonSin;
      case 'Goldfish':
        return fishComonSin;
      case 'Catfish':
        return fishComonSin;
      case 'Angel':
        return fishComonSin;
      case 'Calf':
        return fishComonSin;
      case 'Oska':
        return fishComonSin;
      case 'Gourami':
        return fishComonSin;
      case 'shortTail':
        return fishComonSin;
      case 'Plate':
        return fishComonSin;
      case 'Moli':
        return fishComonSin;
      case 'Kat':
        return fishComonSin;
      case 'Fighter':
        return fishComonSin;
      case 'Zebra':
        return fishComonSin;
      case 'malawiVarieties':
        return fishComonSin;
      case 'Tetra':
        return fishComonSin;
      case 'otherTypesOfFish':
        return fishComonSin;
      case 'Banana':
        return bananaSin;
      case 'Mango':
        return mangoSin;
      case 'sweetcorn':
        return seedscropsCommonSin;
      case 'mungBean':
        return seedscropsCommonSin;
      case 'Pea':
        return seedscropsCommonSin;
      case 'Blades':
        return seedscropsCommonSin;
      case 'Peanut':
        return seedscropsCommonSin;
      case 'Kurakkan':
        return seedscropsCommonSin;
      case 'Millet':
        return seedscropsCommonSin;
      case 'Udu':
        return seedscropsCommonSin;
      case 'Kollu':
        return seedscropsCommonSin;
      case 'Soyabochi':
        return seedscropsCommonSin;
      case 'otherCerealCropsTypes':
        return seedscropsCommonSin;
      case 'litterofLayers':
        return chickenColorSin;
      case 'layersGrownAnimals':
        return chickenColorSin;
      case 'cockaroosChicks':
        return chickenColorSin;
      case 'cockerelGrownAnimals':
        return chickenColorSin;
      case 'broilersLitter':
        return chickenColorSin;
      case 'broilersGrownAnimals':
        return chickenColorSin;
      case 'animalHusbandryEquipment':
        return animalControlEquipmentsTypesSin;
      case 'exportCrops':
        return exportCropsSin;
      case 'exportHarvest':
        return exportHarvestSin;
      case 'exportableByProducts':
        return productionSin;
      case 'exportableAnimals':
        return exportableAnimalsSin;
      case 'Coconuts':
        return coconutTypesSin;
      case 'coconutHustRP':
        return coconutHuskSin;
      case 'fromCopra':
        return copraSin;
      case 'exportCropSeeds':
        return exportingCropsSeedsSin;
      case 'exportCropsPlants':
        return exportingCropsPlantsSin;
      case 'exportCropsPlantingMaterial':
        return exportingCropsPlantingMaterialSin;
      case 'Cinnamon':
        return cinnamonTypesSin;
      case 'coconutShells':
        return fromCoconutShellsSin;
      case 'coconutMeat':
        return fromCoconutMeatSin;
      case 'ricePolish':
        return ricePolishSin;
      case 'Rice':
        return riceSin;
      default:
        return [];
    }
  } else {
    switch (keyword) {
      case 'quadrupeds':
        return fourLegsEn;
      case 'bipeds':
        return depaEn;
      case 'fish':
        return fishEn;
      case 'honeyBee':
        return honeyBeeEn;
      case 'paddy':
        return paddyEN;
      case 'cerealCrops':
        return cerealCropsEn;
      case 'coconut':
        return coconutEn;
      case 'vegetables':
        return vegetablesEn;
      case 'fruits':
        return fruitsEn;
      case 'potato':
        return potatoEn;
      case 'greenleaves':
        return greenLeavesEn;
      case 'flowers':
        return flowersEn;
      case 'cashew':
        return cashewEn;
      case 'forestry':
        return forestryEn;
      case 'mudlands':
        return landsCommonEn;
      case 'lands':
        return landsCommonEn;
      case 'buffalo':
        return buffaloEn;
      case 'cattle':
        return cattleEn;
      case 'goat':
        return goatEn;
      case 'pig':
        return pigEn;
      case 'rabbit':
        return rabbitEn;
      case 'sheep':
        return sheepeEn;
      case 'local':
        return localPaddyEn;
      case 'governmentNotices':
        return governmentNoticesEn;
      case 'prices':
        return pricesEn;
      case 'importTypes':
        return importEN;
      case 'countryShipments':
        return exportTypesEn;
      case 'solidfertilizer':
        return solidFerlizerEn;
      case 'landPreparationEquipment':
        return landPreparationEquEn;
      case 'cultivationEquipment':
        return cultivationEquEn;
      case 'fertilizerApplicationEquipment':
        return fertilizerAppEquEn;
      case 'weedingEquipment':
        return weedingEquEn;
      case 'waterApplicationEquipment':
        return waterAppEquEn;
      case 'harvestingEquipment':
        return harvestingpEquEn;
      case 'coveringEquipment':
        return coveringEquEn;
      case 'safetyEquipment':
        return safetyEquEn;
      case 'Drivers':
        return labourCommonEn;
      case 'wellsandTubeWells':
        return labourCommonEn;
      case 'fixingCoveringEquipment':
        return labourCommonEn;
      case 'installationofSafetyEquipment':
        return labourCommonEn;
      case 'landpreparationworks':
        return labourCommonEn;
      case 'cultivation':
        return labourCommonEn;
      case 'fertilizing':
        return labourCommonEn;
      case 'applicationofAgrochemicals':
        return labourCommonEn;
      case 'weedcontrol':
        return labourCommonEn;
      case 'applyingwater':
        return labourCommonEn;
      case 'harvesting':
        return labourCommonEn;
      case 'laterHarvesting':
        return labourCommonEn;
      case 'postQuestionProcessing':
        return labourCommonEn;
      case 'preparationofbyproducts':
        return labourCommonEn;
      case 'animalHusbandry':
        return labourCommonEn;
      case 'farmManagement':
        return labourCommonEn;
      case 'chickens':
        return chickenEn;
      case 'Turkey':
        return birdsComonEn;
      case 'duck':
        return birdsComonEn;
      case 'vatu':
        return birdsComonEn;
      case 'pigeon':
        return birdsComonEn;
      case 'loveBirds':
        return birdsComonEn;
      case 'gumkukulu':
        return birdsComonEn;
      case 'broilers':
        return broilersEn;
      case 'layers':
        return layersEn;
      case 'cockres':
        return cockresEn;
      case 'parents':
        return birdsComonEn;
      case 'calf':
        return birdsComonEn;
      case 'meat':
        return birdsComonEn;
      case 'medicine':
        return birdsComonEn;
      case 'gear':
        return birdsComonEn;
      case 'freshWater':
        return freshWaterEN;
      case 'saltWater':
        return seaWaterEn;
      case 'ornemantalFish':
        return fancyEn;
      case 'singlefertilizer':
        return singlefertilizerEn;
      case 'pipes':
        return pipesEN;
      case 'eire':
        return cowsComonEn;
      case 'fecian':
        return cowsComonEn;
      case 'jagasi':
        return cowsComonEn;
      case 'glee':
        return cowsComonEn;
      case 'lanka':
        return cowsComonEn;
      case 'sindhi':
        return cowsComonEn;
      case 'amz':
        return cowsComonEn;
      case 'afs':
        return cowsComonEn;
      case 'mura':
        return cowsComonEn;
      case 'nilirawi':
        return cowsComonEn;
      case 'surti':
        return cowsComonEn;
      case 'jamnapari':
        return cowsComonEn;
      case 'satan':
        return cowsComonEn;
      case 'boyer':
        return cowsComonEn;
      case 'kottukavadi':
        return cowsComonEn;
      case 'landiers':
        return fourlegsComonEn;
      case 'largewhite':
        return fourlegsComonEn;
      case 'duro':
        return fourlegsComonEn;
      case 'newzealandwhite':
        return fourlegsComonEn;
      case 'redmadras':
        return fourlegsComonEn;
      case 'seeds':
        return plantingMaterialOrSeedsEn;
      case 'plants':
        return plantingMaterialOrSeedsEn;
      case 'plantingParts':
        return plantingMaterialOrSeedsEn;
      case 'bonsai':
        return plantingMaterialOrSeedsEn;
      case 'import':
        return plantingMaterialOrSeedsCommonEn;
      case 'export':
        return plantingMaterialOrSeedsCommonEn;
      case 'importedlitter':
        return exportSubsEn;
      case 'importedgear':
        return exportSubsEn;
      case 'cattlecalf':
        return cattleTypeEn;
      case 'growncattle':
        return cattleTypeEn;
      case 'buffalocalf':
        return buffaloTypeEn;
      case 'grownbuffalo':
        return buffaloTypeEn;
      case 'goatcalf':
        return goatTypeEn;
      case 'growngoat':
        return goatTypeEn;
      case 'sheepcalf':
        return sheepeTypeEn;
      case 'grownsheep':
        return sheepeTypeEn;
      case 'pigcalf':
        return pigTypeEn;
      case 'grownpig':
        return pigTypeEn;
      case 'rabbitcalf':
        return rabbitTypeEn;
      case 'grownrabbit':
        return rabbitTypeEn;
      case 'agriculturalequipementsandmachinery':
        return agriEqupimentandmachineriesEn;
      case 'Tilapia':
        return fishComonEn;
      case 'Catla':
        return fishComonEn;
      case 'Rohu':
        return fishComonEn;
      case 'Mirihal':
        return fishComonEn;
      case 'freshwaterShrimp':
        return fishComonEn;
      case 'Prawns':
        return fishComonEn;
      case 'Guppy':
        return fishComonEn;
      case 'Goldfish':
        return fishComonEn;
      case 'Catfish':
        return fishComonEn;
      case 'Angel':
        return fishComonEn;
      case 'Calf':
        return fishComonEn;
      case 'Oska':
        return fishComonEn;
      case 'Gourami':
        return fishComonEn;
      case 'shortTail':
        return fishComonEn;
      case 'Plate':
        return fishComonEn;
      case 'Moli':
        return fishComonEn;
      case 'Kat':
        return fishComonEn;
      case 'Fighter':
        return fishComonEn;
      case 'Zebra':
        return fishComonEn;
      case 'malawiVarieties':
        return fishComonEn;
      case 'Tetra':
        return fishComonEn;
      case 'otherTypesOfFish':
        return fishComonEn;
      case 'Banana':
        return bananaEn;
      case 'Mango':
        return mangoEn;
      case 'sweetcorn':
        return seedscropsCommonEn;
      case 'mungBean':
        return seedscropsCommonEn;
      case 'Green':
        return seedscropsCommonEn;
      case 'Pea':
        return seedscropsCommonEn;
      case 'Blades':
        return seedscropsCommonEn;
      case 'Peanut':
        return seedscropsCommonEn;
      case 'Kurakkan':
        return seedscropsCommonEn;
      case 'Millet':
        return seedscropsCommonEn;
      case 'Udu':
        return seedscropsCommonEn;
      case 'Kollu':
        return seedscropsCommonEn;
      case 'Soyabochi':
        return seedscropsCommonEn;
      case 'otherCerealCropsTypes':
        return seedscropsCommonEn;
      case 'litterofLayers':
        return chickenColorEn;
      case 'layersGrownAnimals':
        return chickenColorEn;
      case 'cockaroosChicks':
        return chickenColorEn;
      case 'cockerelGrownAnimals':
        return chickenColorEn;
      case 'broilersLitter':
        return chickenColorEn;
      case 'broilersGrownAnimals':
        return chickenColorEn;
      case 'animalHusbandryEquipment':
        return animalControlEquipmentsTypesEn;
      case 'exportCrops':
        return exportCropsEn;
      case 'exportHarvest':
        return exportHarvestEn;
      case 'exportableByProducts':
        return productionEn;
      case 'paddyrelatedproducts':
        return paddyrelatedproductsEn;
      case 'coconutrelatedproducts':
        return coconutrelatedproductsEn;
      case 'flowersrelatedproducts':
        return flowersrelatedproductsEn;
      case 'forestryrelatedproducts':
        return forestryrelatedproductsEn;
      case 'othercerealcropsrelatedproducts':
        return cerealCropsEn;
      // case 'seeds':
      //   return seedsListEn;
      // case 'plants':
      //   return palntListEn;
      // case 'plantingmaterial':
      //   return plantingmaterialListEn;
      case 'exportableAnimals':
        return exportableAnimalsEn;
      case 'Coconuts':
        return coconutTypesEn;
      case 'coconutHustRP':
        return coconutHuskEn;
      case 'fromCopra':
        return copraEn;
      case 'exportCropSeeds':
        return exportingCropsSeedsEn;
      case 'exportCropsPlants':
        return exportingCropsPlantsEn;
      case 'exportCropsPlantingMaterial':
        return exportingCropsPlantingMaterialEn;
      case 'Cinnamon':
        return cinnamonTypesEn;
      case 'coconutShells':
        return fromCoconutShellsEn;
      case 'coconutMeat':
        return fromCoconutMeatEn;
      case 'ricePolish':
        return ricePolishEn;
      case 'Rice':
        return riceEn;

      default:
        return [];
    }
  }
}

List<String> pathChangers = [
  'local',
  'cattle',
  'buffalo',
  'goat',
  'pig',
  'rabbit',
  'sheep',
  'duck',
  'Turkey',
  'vatu',
  'pigeon',
  'loveBirds',
  'chickens',
  'gumkukulu',
  'broilers',
  'layers',
  'parents',
  'cockres',
  'freshWater',
  'ornemantalFish',
  'saltWater',
  'singlefertilizer',
  'pipes',
  'smallanimals',
  'importedgear',
  'cattlecalf',
  'buffalocalf',
  'goatcalf',
  'sheepcalf',
  'pigcalf',
  'rabbitcalf',
  'agriculturalequipementsandmachinery',
  'Tilapia',
  'Catla',
  'Rohu',
  'Mirihal',
  'freshwaterShrimp',
  'Prawns',
  'Guppy',
  'Goldfish',
  'Catfish',
  'Angel',
  'Calf',
  'Oska',
  'Gourami',
  'shortTail',
  'Plate',
  'Moli',
  'Kat',
  'Fighter',
  'Zebra',
  'malawiVarieties',
  'Tetra',
  'otherTypesOfFish',
  'Banana',
  'Mango',
  'sweetcorn',
  'Green',
  'mungBean',
  'Pea',
  'Blades',
  'Peanut',
  'Kurakkan',
  'Millet',
  'Udu',
  'Kollu',
  'Soyabochi',
  'otherCerealCropsTypes',
  'animalHusbandryEquipment',
  'litterofLayers',
  'layersGrownAnimals',
  'cockerelGrownAnimals',
  'broilersGrownAnimals',
  'broilersLitter',
  'cockaroosChicks',
  'exportHarvest',
  'exportCrops',
  'exportableByProducts',
  'seeds',
  'plants',
  'plantingParts',
  'bonsai',
  'plantingmaterial',
  'exportableAnimals',
  'Coconuts',
  'coconutHustRP',
  'fromCopra',
  'growncattle',
  'grownbuffalo',
  'growngoat',
  'grownsheep',
  'grownpig',
  'grownrabbit',
  'exportCropSeeds',
  'exportCropsPlants',
  'exportCropsPlantingMaterial',
  'Cinnamon',
  'coconutShells',
  'coconutMeat',
  'ricePolish',
  'Rice',
];

List getFilteringListsFromName(String keyword) {
  switch (keyword) {
    case 'Paddy':
      return [paddyKg, prizeRange];
    case 'Lands':
      return [landsSize];
    case 'Hand Tractor':
      return [vehiclesSin];
    case 'Tractor':
      return [vehiclesSin];
    case 'Spare Parts':
      return [vehiclesSin];
    // case 'Flowers':
    //   return [flowersFSin];
    // case 'Boga':
    //   return bogaSin;
    case 'Fruits':
      return [paddyKg, prizeRange];
    case 'Vegetables':
      return [vegetables, paddyKg, prizeRange];
    case 'Potato':
      return [potatoes, paddyKg, prizeRange];
    // case 'Locale':
    //   return [paddyColors, paddyWhiteType, paddyKg];
    case 'greenLeaves':
      return [paddyKg];
    case 'Drivers':
      return [labourSelectorSin];
    // case 'exportCrops':
    //   return [export];
    default:
      return [];
  }
}

//selector connector
List<String> nameSelector(String keyword, String lan) {
  if (lan == 'si') {
    switch (keyword) {
      case 'Paddy':
        return ["කිලෝ පරාසය", "මිල පරාසය"];
      case 'Lands':
        return ["අක්කර ප්‍රමාණය"];
      case 'Hand Tractor':
        return ["තත්වය"];
      case 'Tractor':
        return ["තත්වය"];
      case 'Spare Parts':
        return ["තත්වය"];
      // case 'Flowers':
      //   return [flowersFSin];
      // case 'Boga':
      //   return bogaSin;
      case 'Fruits':
        return ["කිලෝ පරාසය", "මිල පරාසය"];
      case 'Vegetables':
        return ["කිලෝ පරාසය", "මිල පරාසය"];
      case 'Potato':
        return ["කිලෝ පරාසය", "මිල පරාසය"];

      case 'greenLeaves':
        return ["කිලෝ පරාසය"];
      case 'Drivers':
        return ["ශ්රම සුදුසුකම්"];
      default:
        return [];
    }
  } else {
    switch (keyword) {
      case 'Paddy':
        return ["Acreage", "Kilo range"];
      case 'Lands':
        return ["Acreage"];
      case 'Hand Tractor':
        return ["Condition"];
      case 'Tractor':
        return ["Condition"];
      case 'Spare Parts':
        return ["Condition"];
      // case 'Flowers':
      //   return [flowersFSin];
      // case 'Boga':
      //   return bogaSin;
      case 'Fruits':
        return ["Kilo range", "Price range"];
      case 'Vegetables':
        return ["Kilo range", "Price range"];
      case 'Potato':
        return ["Kilo range", "Price range"];

      case 'greenLeaves':
        return ["Kilo range"];
      case 'Drivers':
        return ["Labor Qualification"];
      default:
        return [];
    }
  }
}

// price list
String priceseNames(AppLocalizations localizations, String keyword) {
  switch (keyword) {
    case 'Rent':
      return localizations.priceForOnekg;
    default:
      return localizations.price;
  }
}
