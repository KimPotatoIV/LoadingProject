'''
로딩 화면 이전 나타나는 Splash Screen(or Launch Image)은
Project - Project Settings... - Boot Splash에서 설정 가능
'''

extends Node2D

##################################################
# 로드할 씬 파일의 경로
const GAME_WORLD_SCENE_PATH: String = "res://scenes/game_world/game_world.tscn"
# 로딩 화면을 최소 몇 초 동안 보여줄지
const MIN_LOADING_TIME: float = 2.0

# 로딩 화면이 켜진 이후 누적된 시간
var elapsed_time: float = 0.0
# 로딩 진행률을 반환받기 위한 배열
var progress_array: Array = []

# ProgressBar 노드 참조
@onready var progress_bar_node: ProgressBar = \
$CanvasLayer/MarginContainer/VBoxContainer/ProgressBar

##################################################
func _ready() -> void:
	# 내부적으로 백그라운드 스레드에 리소스 로드를 요청하며 즉시 반환
	# 여러 씬을 불러와도 path로 구분되므로 별도의 변수에 결과를 담지 않아도 됨
	ResourceLoader.load_threaded_request(GAME_WORLD_SCENE_PATH)

##################################################
func _process(delta: float) -> void:
	# 매 프레임마다 delta를 누적하여 경과 시간을 계산
	elapsed_time += delta
	
	# 백그라운드로 요청한 씬의 현재 로딩 상태를 조회
	# load_threaded_get_status()는 두 번째 인자 배열에 진행률 정보 담음
	var loading_status = \
		ResourceLoader.load_threaded_get_status(GAME_WORLD_SCENE_PATH, progress_array)
	# 로딩 완료 및 로딩 시간까지 지났다면 씬 전환
	if loading_status == ResourceLoader.THREAD_LOAD_LOADED and \
		elapsed_time >= MIN_LOADING_TIME:
		# load_threaded_get()는 이미 백그라운드에서 준비된 리소스를 반환
		var loaded_scene: PackedScene = \
			ResourceLoader.load_threaded_get(GAME_WORLD_SCENE_PATH)
		# 준비된 PackedScene으로 씬 전환을 수행
		get_tree().change_scene_to_packed(loaded_scene)
	# 로딩이 아직 진행 중일 때 ProgressBar를 갱신
	else:
		# progress_array가 비어있지 않을 때
		if not progress_array.is_empty():
			# 진행률은 배열의 0번째 요소로 0.0~1.0을 반환
			var progress: float = progress_array[0]
			# ProgressBar의 value를 갱신
			progress_bar_node.value = progress * 100.0
