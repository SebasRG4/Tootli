import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_favourite_widget.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/home/controllers/advertisement_controller.dart';
import 'package:sixam_mart/features/home/domain/models/advertisement_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:video_player/video_player.dart';

class HighlightWidget extends StatefulWidget {
  const HighlightWidget({super.key});

  @override
  State<HighlightWidget> createState() => _HighlightWidgetState();
}

class _HighlightWidgetState extends State<HighlightWidget> {

  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      return advertisementController.advertisementList != null && advertisementController.advertisementList!.isNotEmpty ? Padding(
        padding: const EdgeInsets.only(
          
        //top: Dimensions.paddingSizeDefault, 
        //bottom: Dimensions.paddingSizeDefault
        ),
        child: Stack(
          children: [

            CustomAssetImageWidget(
              Get.isDarkMode ? Images.highlightDarkBg : Images.highlightBg, width: context.width,
              fit: BoxFit.cover,
              borderRadius: 5
            ),

            Column(children: [

              Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault, 
                  top: Dimensions.paddingSizeSmall, 
                  //bottom: Dimensions.paddingSizeExtraSmall,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('highlights_for_you'.tr, 
                      style: robotoBlack.copyWith(
                        fontSize: Dimensions.fontSizeLarge, 
                        color: Colors.white)),
                      
                      const SizedBox(width: 5),

                      Text('see_our_most_popular_store_and_item'.tr, 
                      style: robotoBold.copyWith(
                        color: Theme.of(context).disabledColor, 
                        fontSize: Dimensions.fontSizeSmall)),
                    ],
                  ),

                  /*const CustomAssetImageWidget(
                    Images.highlightIcon, height: 50, width: 50,
                  ),*/


                ]),
              ),

              CarouselSlider.builder(
  carouselController: _carouselController,
  itemCount: advertisementController.advertisementList!.length,
  options: CarouselOptions(
    enableInfiniteScroll: advertisementController.advertisementList!.length > 1,
    autoPlay: advertisementController.autoPlay,
    autoPlayInterval: const Duration(seconds: 15),
    enlargeCenterPage: false,
    height: 280,
    viewportFraction: 1,
    disableCenter: true,
    onPageChanged: (index, reason) {
      // Al cambiar de página, actualizar el índice actual
      advertisementController.setCurrentIndex(index, true);
      
      // Actualizar el estado de reproducción automática según el tipo
      if (advertisementController.advertisementList?[index].addType == "video_promotion") {
        advertisementController.updateAutoPlayStatus(status: false);
      } else {
        advertisementController.updateAutoPlayStatus(status: true);
      }
    },
  ),
  itemBuilder: (context, index, realIndex) {
    // Pasar el estado activo al widget de video
    return advertisementController.advertisementList?[index].addType == 'video_promotion' 
      ? HighlightVideoWidget(
          advertisement: advertisementController.advertisementList![index],
          isActive: advertisementController.currentIndex == index, // Pasar el estado activo
        ) 
      : HighlightStoreWidget(
          advertisement: advertisementController.advertisementList![index]
        );
  },
),

              const AdvertisementIndicator(),

              //const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

            ]),
          ],
        ),
      ) : advertisementController.advertisementList == null ? const AdvertisementShimmer() : const SizedBox();
    });
  }
}

class HighlightStoreWidget extends StatelessWidget {
  final AdvertisementModel advertisement;
  const HighlightStoreWidget({super.key, required this.advertisement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.07), width: 2),
      ),
      child: TextHover(
        builder: (hovered) {
          return InkWell(
            onTap: (){
              Get.toNamed(RouteHelper.getStoreRoute(id: advertisement.storeId, page: 'store'),
                arguments: StoreScreen(store: Store(id: advertisement.storeId), fromModule: false),
              );
            },
            child: Column(children: [

              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                  child: Stack(
                    children: [
                      CustomImage(
                        isHovered: hovered,
                        image: advertisement.coverImageFullUrl ?? '',
                        fit: BoxFit.cover, height: 160, width: double.infinity,
                      ),

                      (advertisement.isRatingActive == 1 || advertisement.isReviewActive == 1) ? Positioned(
                        right: 10, bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Theme.of(context).cardColor, width: 2),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 0)],
                          ),
                          child: Row(
                            children: [
                              advertisement.isRatingActive == 1 ? Icon(Icons.star, color: Theme.of(context).cardColor, size: 15) : const SizedBox(),
                              SizedBox(width: advertisement.isRatingActive == 1 ? 5 : 0),

                              advertisement.isRatingActive == 1 ? Text('${advertisement.averageRating?.toStringAsFixed(1)}', style: robotoBold.copyWith(color: Theme.of(context).cardColor)) : const SizedBox(),
                              SizedBox(width: advertisement.isRatingActive == 1 ? 5 : 0),

                              advertisement.isReviewActive == 1 ? Text('(${advertisement.reviewsCommentsCount})', style: robotoRegular.copyWith(color: Theme.of(context).cardColor)) : const SizedBox(),
                            ],
                          ),
                        ),
                      ) : const SizedBox(),

                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 2),
                      ),
                      child: ClipOval(
                        child: CustomImage(
                          image: advertisement.profileImageFullUrl ?? '',
                          height: 60, width: 60, fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Flexible(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                          Flexible(
                            child: Text(
                              advertisement.title ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                              maxLines: 1, overflow: TextOverflow.ellipsis
                            ),
                          ),

                          GetBuilder<FavouriteController>(builder: (favouriteController) {
                            bool isWished = favouriteController.wishStoreIdList.contains(advertisement.storeId);
                            return CustomFavouriteWidget(
                              isWished: isWished,
                              isStore: true,
                              storeId: advertisement.storeId,
                            );
                          }),

                        ]),
                        const SizedBox(height: 3),

                        Text(
                          advertisement.description ?? '',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),

                      ]),
                    ),


                  ]),
                ),
              ),

            ]),
          );
        }
      ),
    );
  }
}

class HighlightVideoWidget extends StatefulWidget {
  final AdvertisementModel advertisement;
  final bool isActive;
  
  const HighlightVideoWidget({
    super.key, 
    required this.advertisement,
    this.isActive = true,
  });

  @override
  State<HighlightVideoWidget> createState() => _HighlightVideoWidgetState();
}

class _HighlightVideoWidgetState extends State<HighlightVideoWidget> {
  VideoPlayerController? _videoPlayerController;  // Hacer nullable
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isDisposed = false;  // Flag para controlar si el widget está dispuesto

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(HighlightVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Verificar que el controlador existe antes de usarlo
    if (_videoPlayerController == null || _isDisposed) return;
    
    // Detectar cambios en el estado activo
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        // Este widget se activó, reanudar reproducción
        _chewieController?.play();
      } else {
        // Este widget ya no está activo, pausar y silenciar completamente
        _stopVideo();
      }
    }
  }

  Future<void> _initializePlayer() async {
    if (_isDisposed) return;  // No continuar si el widget ya está dispuesto
    
    try {
      final String videoUrl = widget.advertisement.videoAttachmentFullUrl ?? "";
      if (videoUrl.isEmpty) {
        if (!_isDisposed && mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
        return;
      }

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      // Inicializa el controlador con un timeout para evitar bloqueos indefinidos
      await _videoPlayerController?.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (!_isDisposed && mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
          return;
        },
      );

      if (_isDisposed || !mounted) return;

      // Verificar si el controlador fue inicializado correctamente
      if (_videoPlayerController?.value.isInitialized ?? false) {
        // Agregar listener para cuando el video termina
        _videoPlayerController?.addListener(_videoListener);
        
        // Asegurarse de que el volumen está en cero inicialmente
        await _videoPlayerController?.setVolume(0);

        // Crear el controlador Chewie
        _createChewieController();
        
        // Solo reproducir si este widget está activo
        if (widget.isActive) {
          _chewieController?.play();
        } else {
          _videoPlayerController?.pause();
        }
      } else {
        _hasError = true;
      }

      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      debugPrint('Error al inicializar el video: $e');
    }
  }

  void _videoListener() {
    // Verificar si el widget o controlador están dispuestos
    if (_isDisposed || _videoPlayerController == null) return;
    
    if (_videoPlayerController!.value.isInitialized &&
        _videoPlayerController!.value.position >= _videoPlayerController!.value.duration - const Duration(milliseconds: 300)) {
      // Video terminó o está cerca del final
      final delay = GetPlatform.isWeb ? const Duration(seconds: 4) : Duration.zero;
      Future.delayed(delay, () {
        // Verificar que el controlador de anuncios todavía existe
        if (!_isDisposed && Get.isRegistered<AdvertisementController>()) {
          final advertisementController = Get.find<AdvertisementController>();
          advertisementController.updateAutoPlayStatus(status: true, shouldUpdate: true);
        }
      });
    }
  }

  void _createChewieController() {
    if (_isDisposed || _videoPlayerController == null || !(_videoPlayerController!.value.isInitialized)) return;
    
    final aspectRatio = _videoPlayerController!.value.aspectRatio * 
        (ResponsiveHelper.isDesktop(context) ? 1 : 1.3);
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: widget.isActive,
      aspectRatio: aspectRatio,
      allowMuting: true,
      errorBuilder: (context, errorMessage) {
        return const Center(
          child: Text(
            'Error al cargar el video',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
    
    // Configurar volumen a 0 (silencio)
    _chewieController?.setVolume(0);
  }

  // Parar completamente el video de manera segura
  void _stopVideo() {
    if (_isDisposed || _videoPlayerController == null) return;
    
    if (_videoPlayerController!.value.isInitialized) {
      _videoPlayerController!.pause();
      _videoPlayerController!.setVolume(0);
      
      // No usar seekTo si el widget está siendo dispuesto
      if (!_isDisposed) {
        _videoPlayerController!.seekTo(Duration.zero);
      }
    }
  }

  @override
  void dispose() {
    // Marcar como dispuesto antes de cualquier operación
    _isDisposed = true;
    
    // Remover listener de forma segura
    if (_videoPlayerController != null) {
      // Es seguro remover un listener incluso si no existe
      _videoPlayerController!.removeListener(_videoListener);
      _videoPlayerController!.dispose();
    }
    
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).disabledColor.withAlpha(18), 
          width: 2
        ),
      ),
      child: Column(children: [
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Dimensions.radiusDefault)
            ),
            child: Stack(
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_hasError)
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'No se pudo cargar el video',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                else if (_chewieController != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                  Container(
                    color: Colors.black,
                    child: Chewie(controller: _chewieController!),
                  ),
              ],
            ),
          ),
        ),
        
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                widget.advertisement.title ?? '',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge, 
                  fontWeight: FontWeight.w600
                ),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text(
                    widget.advertisement.description ?? '',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall, 
                      color: Theme.of(context).hintColor
                    ),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                InkWell(
                  onTap: () {
                    // Detener el video antes de navegar
                    _stopVideo();
                    
                    // Pequeño retraso para asegurar que se detuvo
                    Future.delayed(Duration.zero, () {
                      Get.toNamed(
                        RouteHelper.getStoreRoute(id: widget.advertisement.storeId, page: 'store'),
                        arguments: StoreScreen(
                          store: Store(id: widget.advertisement.storeId), 
                          fromModule: false
                        ),
                      );
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Icon(
                      Icons.arrow_forward, 
                      color: Theme.of(context).cardColor, 
                      size: 20
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class AdvertisementIndicator extends StatelessWidget {
  const AdvertisementIndicator({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      return advertisementController.advertisementList != null && advertisementController.advertisementList!.length > 2 ?
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(height: 7, width: 7,
          decoration:  BoxDecoration(color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: advertisementController.advertisementList!.map((advertisement) {
            int index = advertisementController.advertisementList!.indexOf(advertisement);
            return index == advertisementController.currentIndex ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 3),
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                  color:  Theme.of(context).primaryColor ,
                  borderRadius: BorderRadius.circular(50)),
              child:  Text("${index+1}/ ${advertisementController.advertisementList!.length}",
                style: const TextStyle(color: Colors.white,fontSize: 12),),
            ):const SizedBox();
          }).toList(),
        ),
        Container(
          height: 7, width: 7,
          decoration:  BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ]): advertisementController.advertisementList != null && advertisementController.advertisementList!.length == 2 ?
      Align(
        alignment: Alignment.center,
        child: AnimatedSmoothIndicator(
          activeIndex: advertisementController.currentIndex,
          count: advertisementController.advertisementList!.length,
          effect: ExpandingDotsEffect(
            dotHeight: 7,
            dotWidth: 7,
            spacing: 5,
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotColor: Theme.of(context).hintColor.withValues(alpha: 0.6),
          ),
        ),
      ): const SizedBox();
    });
  }
}

class AdvertisementShimmer extends StatelessWidget {
  const AdvertisementShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
        ),
        margin:  EdgeInsets.only(
          top: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge * 3.5 : 0 ,
          right: Get.find<LocalizationController>().isLtr && ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0,
          left: !Get.find<LocalizationController>().isLtr && ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0,
        ),
        child: Padding( padding : const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: Dimensions.paddingSizeLarge,),

              Container(height: 20, width: 200,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).shadowColor
                ),),

              const SizedBox(height: Dimensions.paddingSizeSmall,),

              Container(height: 15, width: 250,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).shadowColor,
                ),),

              const SizedBox(height: Dimensions.paddingSizeDefault * 2,),

              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: ResponsiveHelper.isDesktop(context) ? 3 : 1,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: ResponsiveHelper.isDesktop(context) ? (Dimensions.webMaxWidth - 20) / 3 : MediaQuery.of(context).size.width,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(padding: const EdgeInsets.only(bottom: 0, left: 10, right: 10),
                            child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                color: Theme.of(context).shadowColor,
                                border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2),),
                              ),
                              padding: const EdgeInsets.only(bottom: 25),
                              child: const Center(child: Icon(Icons.play_circle, color: Colors.white,size: 45,),),
                            ),
                          ),

                          Positioned( bottom: 0, left: 0,right: 0, child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                color: Theme.of(context).cardColor,
                                border: Border.all(color: Theme.of(context).shadowColor)
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: Column(children: [
                              Row( children: [

                                Expanded(
                                  child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Container(
                                      height: 17, width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        color: Theme.of(context).shadowColor,
                                      ),
                                    ),

                                    const SizedBox(height: Dimensions.paddingSizeSmall,),
                                    Container(
                                      height: 17, width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        color: Theme.of(context).shadowColor,
                                      ),
                                    ),

                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                                    Container(
                                      height: 17, width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        color: Theme.of(context).shadowColor,
                                      ),
                                    )
                                  ]),
                                ),

                                const SizedBox(width: Dimensions.paddingSizeLarge,),

                                InkWell(
                                  onTap: () => Get.back(),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall + 5, vertical: Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: Theme.of(context).shadowColor,
                                    ),
                                    child:  Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white.withValues(alpha: 0.8),),
                                  ),
                                )
                              ],)
                            ],),
                          ))
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge * 2,),

              Align(
                alignment: Alignment.center,
                child: AnimatedSmoothIndicator(
                  activeIndex: 0,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    dotHeight: 7,
                    dotWidth: 7,
                    spacing: 5,
                    activeDotColor: Theme.of(context).disabledColor,
                    dotColor: Theme.of(context).hintColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
            ],
          ),
        ),
      ),
    );
  }
}