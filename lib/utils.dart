String getBMICategoryInfo(String category) {
  switch (category.toLowerCase()) {
    case 'severe underweight':
      return 'Severe underweight increases health risks. Please consult a healthcare provider.';
    case 'underweight':
      return 'Being underweight may cause health issues. Consider a balanced diet and consult a professional.';
    case 'normal':
      return 'You are within the healthy BMI range. Maintain your current lifestyle!';
    case 'overweight':
      return 'Overweight increases risk for some diseases. Consider healthy eating and regular exercise.';
    case 'obese':
      return 'Obesity can lead to serious health problems. Consult a doctor for a personalized plan.';
    case 'severe obesity':
      return 'Severe obesity is dangerous. Seek medical advice immediately.';
    default:
      return 'No information available for this category.';
  }
}
