import 'package:flutter/material.dart';
import '../models/category.dart';
import '../constants/colors.dart';

final List<Category> defaultCategories = [
  const Category(
    id: 'greetings',
    name: '인사/소개',
    nameEn: 'Greetings',
    icon: Icons.waving_hand,
    color: AppColors.catGreetings,
    phraseCount: 35,
  ),
  const Category(
    id: 'restaurant',
    name: '식당',
    nameEn: 'Restaurant',
    icon: Icons.restaurant,
    color: AppColors.catRestaurant,
    phraseCount: 35,
  ),
  const Category(
    id: 'shopping',
    name: '쇼핑',
    nameEn: 'Shopping',
    icon: Icons.shopping_bag,
    color: AppColors.catShopping,
    phraseCount: 30,
  ),
  const Category(
    id: 'travel',
    name: '여행',
    nameEn: 'Travel',
    icon: Icons.flight,
    color: AppColors.catTravel,
    phraseCount: 35,
  ),
  const Category(
    id: 'workplace',
    name: '직장',
    nameEn: 'Workplace',
    icon: Icons.business_center,
    color: AppColors.catWorkplace,
    phraseCount: 35,
  ),
  const Category(
    id: 'emergency',
    name: '긴급상황',
    nameEn: 'Emergency',
    icon: Icons.emergency,
    color: AppColors.catEmergency,
    phraseCount: 30,
  ),
];
